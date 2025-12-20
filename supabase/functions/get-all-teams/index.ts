import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    )

    const { data, error } = await supabaseClient
      .from('teams')
      .select('team_name, team_conference, team_division, logo_url')

    if (error) throw error

    // Transform data to match frontend expectations if necessary, 
    // but here we align the select alias or map in JS.
    // Frontend expects: team_name, team_conference, team_division, logo_url
    // Let's map it here to be safe and clean.
    const mappedData = data.map(team => ({
      team_name: team.team_name,
      team_conference: team.team_conference,
      team_division: team.team_division,
      logo_url: team.logo_url
    }));



    return new Response(JSON.stringify(mappedData), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})
