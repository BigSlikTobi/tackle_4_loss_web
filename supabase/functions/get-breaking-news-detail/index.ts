// @ts-nocheck
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    )

    const { id } = await req.json()

    if (!id) {
      throw new Error('Missing ID parameter')
    }

    const { data, error } = await supabaseClient
      .schema('content')
      .from('breaking_news')
      .select('id, headline, created_at, content, introduction, source_url, tts_file, article_images(image_url, source)')
      .eq('id', id)
      .single()

    if (error) throw error

    const images = Array.isArray(data.article_images) ? data.article_images[0] : data.article_images

    const mappedData = {
      id: data.id,
      headline: data.headline,
      created_at: data.created_at,
      content: data.content,
      introduction: data.introduction,
      source_url: data.source_url,
      image_url: images?.image_url,
      image_source: images?.source,
      audio_file: data.tts_file
    }

    return new Response(JSON.stringify(mappedData), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})
