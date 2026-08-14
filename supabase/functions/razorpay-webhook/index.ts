import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
const cors={"Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"content-type,x-razorpay-signature"};
async function hmac(secret:string, body:string){const key=await crypto.subtle.importKey("raw",new TextEncoder().encode(secret),{name:"HMAC",hash:"SHA-256"},false,["sign"]);const sig=await crypto.subtle.sign("HMAC",key,new TextEncoder().encode(body));return [...new Uint8Array(sig)].map(b=>b.toString(16).padStart(2,"0")).join("");}
Deno.serve(async(req)=>{
 if(req.method!=="POST") return new Response("ok",{headers:cors});
 const raw=await req.text();
 try{
  const secret=Deno.env.get("RAZORPAY_WEBHOOK_SECRET"); if(!secret) throw new Error("Webhook secret not configured");
  const incoming=req.headers.get("x-razorpay-signature")||""; const expected=await hmac(secret,raw); if(incoming!==expected) return new Response("Invalid signature",{status:401,headers:cors});
  const event=JSON.parse(raw); const entity=event?.payload?.subscription?.entity; if(!entity) return new Response("ignored",{status:200,headers:cors});
  const ownerId=entity?.notes?.owner_id; const plan=entity?.notes?.plan; if(!ownerId||!plan) return new Response("missing notes",{status:200,headers:cors});
  const sb=createClient(Deno.env.get("SUPABASE_URL")!,Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
  const active=["subscription.activated","subscription.authenticated","subscription.charged","subscription.resumed"].includes(event.event);
  const inactive=["subscription.cancelled","subscription.halted","subscription.completed","subscription.paused","subscription.pending"].includes(event.event);
  const status=active?"active":inactive?event.event.split(".")[1]:event.event.split(".")[1]||entity.status;
  const end=entity.current_end?new Date(entity.current_end*1000).toISOString():null;
  await sb.from("subscriptions").upsert({owner_id:ownerId,plan,status,provider:"razorpay",provider_subscription_id:entity.id,current_period_end:end,updated_at:new Date().toISOString()},{onConflict:"provider_subscription_id"});
  await sb.from("businesses").update({plan:active?plan:"free",subscription_status:status,subscription_ends_at:end}).eq("owner_id",ownerId);
  return new Response("ok",{status:200,headers:cors});
 }catch(e){console.error(e);return new Response("Webhook error",{status:500,headers:cors});}
});
