import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const cors = {"Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"authorization, x-client-info, apikey, content-type"};
Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", {headers:cors});
  try {
    const auth = req.headers.get("Authorization");
    if (!auth) throw new Error("Not authenticated");
    const supabase = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_ANON_KEY")!, {global:{headers:{Authorization:auth}}});
    const {data:{user},error:ue}=await supabase.auth.getUser();
    if (ue || !user) throw new Error("Not authenticated");
    const {plan,email}=await req.json();
    if (!["pro","business"].includes(plan)) throw new Error("Invalid plan");
    const planId = plan === "pro" ? Deno.env.get("RAZORPAY_PRO_PLAN_ID") : Deno.env.get("RAZORPAY_BUSINESS_PLAN_ID");
    const keyId=Deno.env.get("RAZORPAY_KEY_ID"), keySecret=Deno.env.get("RAZORPAY_KEY_SECRET");
    if (!planId || !keyId || !keySecret) throw new Error("Razorpay is not configured yet. Add the Razorpay environment variables to this function.");
    const basic=btoa(`${keyId}:${keySecret}`);
    const body={plan_id:planId,total_count:120,quantity:1,customer_notify:true,notes:{owner_id:user.id,plan,email:email||user.email}};
    const r=await fetch("https://api.razorpay.com/v1/subscriptions",{method:"POST",headers:{Authorization:`Basic ${basic}`,"Content-Type":"application/json"},body:JSON.stringify(body)});
    const data=await r.json();
    if(!r.ok) throw new Error(data?.error?.description||"Razorpay subscription creation failed");
    const {error:ie}=await supabase.from("subscriptions").upsert({owner_id:user.id,plan,status:data.status||"created",provider:"razorpay",provider_subscription_id:data.id},{onConflict:"provider_subscription_id"});
    if(ie) console.error(ie);
    return new Response(JSON.stringify({subscription_id:data.id,key_id:keyId}),{headers:{...cors,"Content-Type":"application/json"}});
  } catch(e) { return new Response(JSON.stringify({error:e instanceof Error?e.message:"Unknown error"}),{status:400,headers:{...cors,"Content-Type":"application/json"}}); }
});
