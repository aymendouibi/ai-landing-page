<?php

namespace App\Services\AI\Prompts;

class UnifiedWebsitePrompt
{
    /**
     * Build unified generation prompt producing high-converting copy and section data in a single high-speed round-trip.
     *
     * @param string $userPrompt
     * @param string|null $industry
     * @return array<array{role: string, content: string}>
     */
    public static function build(string $userPrompt, ?string $industry = null): array
    {
        $industryContext = $industry ? "The preferred industry is: {$industry}." : "";

        $system = <<<PROMPT
You are a world-class website architect, design strategist, and direct-response copywriter.
Your task is to take a business concept and generate complete, authentic, high-converting website content across all standard sections.
Keep all copy punchy, crisp, and under 30 words per field for maximum mobile readability.
Do not invent fake regulatory claims, specific false certifications, or deceptive customer names.
Provide compelling, sophisticated copywriting tailored to the brand identity.
You MUST output pure, valid JSON only. Do not wrap in markdown or backticks.
PROMPT;

        $user = <<<PROMPT
Create a complete website specification for this business:
"{$userPrompt}"
{$industryContext}

Respond with pure JSON conforming exactly to this structure:
{
  "business_name": "string (brand/business name)",
  "industry": "string (e.g. Technology, SaaS, Architecture, Restaurant, Agency, Portfolio)",
  "tagline": "string (concise 1-sentence brand proposition)",
  "hero": {
    "headline": "string (strong high-impact value proposition)",
    "subheadline": "string (explanatory subheadline)",
    "ctaText": "string (primary button label, e.g. Explore Projects, Get Started)",
    "ctaLink": "#features",
    "secondaryCtaText": "string (secondary button label, e.g. Book Consultation, Contact Us)",
    "secondaryCtaLink": "#contact"
  },
  "features": {
    "title": "string (features section title)",
    "subtitle": "string (supporting subtitle)",
    "items": [
      {
        "icon": "zap | shield | sparkles | activity | check-circle | heart | target",
        "title": "string",
        "description": "string"
      },
      {
        "icon": "zap | shield | sparkles | activity | check-circle | heart | target",
        "title": "string",
        "description": "string"
      },
      {
        "icon": "zap | shield | sparkles | activity | check-circle | heart | target",
        "title": "string",
        "description": "string"
      }
    ]
  },
  "about": {
    "headline": "string",
    "description": "string (2-3 sentences about methodology, background, or vision)",
    "highlights": ["string", "string", "string"]
  },
  "statistics": {
    "items": [
      { "value": "string (e.g. 150+, 99.9%, 10k+)", "label": "string" },
      { "value": "string (e.g. 18, 24/7, 4.9/5)", "label": "string" },
      { "value": "string (e.g. 100%, 15+, 50+)", "label": "string" }
    ]
  },
  "testimonials": {
    "items": [
      {
        "quote": "string",
        "author": "string",
        "role": "string"
      },
      {
        "quote": "string",
        "author": "string",
        "role": "string"
      }
    ]
  },
  "cta": {
    "headline": "string (compelling call to action)",
    "description": "string",
    "buttonText": "string",
    "buttonLink": "#contact"
  },
  "contact": {
    "title": "string",
    "description": "string"
  },
  "seo": {
    "title": "string (Page Title under 60 chars)",
    "description": "string (Meta description under 160 chars)"
  }
}
PROMPT;

        return [
            ['role' => 'system', 'content' => $system],
            ['role' => 'user', 'content' => $user],
        ];
    }
}
