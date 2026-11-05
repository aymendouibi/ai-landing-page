<?php

namespace App\Services\AI\Prompts;

class ContentGenerationPrompt
{
    /**
     * @param array<string, mixed> $businessAnalysis
     * @param array<string, mixed> $plan
     * @return array<array{role: string, content: string}>
     */
    public static function build(array $businessAnalysis, array $plan): array
    {
        $system = <<<PROMPT
You are a world-class copywriter and UX content designer.
Generate compelling, high-converting copy for each section of the planned website.
Do not invent fake regulatory claims, specific false certifications, or deceptive customer names.
Provide authentic, professional copywriting tailored to the business.

Respond with pure JSON only:
{
  "sections_content": [
    {
      "component": "hero",
      "props": {
        "headline": "string",
        "subheadline": "string",
        "ctaText": "string",
        "ctaLink": "#contact",
        "secondaryCtaText": "string",
        "secondaryCtaLink": "#features"
      }
    },
    {
      "component": "features",
      "props": {
        "title": "string",
        "subtitle": "string",
        "items": [
          { "icon": "zap | shield | sparkles | activity | check-circle | heart | target", "title": "string", "description": "string" }
        ]
      }
    },
    {
      "component": "about",
      "props": {
        "headline": "string",
        "description": "string",
        "highlights": ["string", "string", "string"]
      }
    },
    {
      "component": "statistics",
      "props": {
        "items": [
          { "value": "string", "label": "string" }
        ]
      }
    },
    {
      "component": "testimonials",
      "props": {
        "title": "string",
        "items": [
          { "quote": "string", "author": "string", "role": "string", "rating": 5 }
        ]
      }
    },
    {
      "component": "faq",
      "props": {
        "title": "string",
        "subtitle": "string",
        "items": [
          { "question": "string", "answer": "string" }
        ]
      }
    },
    {
      "component": "cta",
      "props": {
        "headline": "string",
        "description": "string",
        "buttonText": "string",
        "buttonLink": "#contact"
      }
    },
    {
      "component": "contact",
      "props": {
        "title": "string",
        "description": "string",
        "email": "string",
        "phone": "string",
        "address": "string"
      }
    },
    {
      "component": "footer",
      "props": {
        "copyright": "string",
        "links": [
          { "label": "string", "href": "string" }
        ]
      }
    }
  ]
}
PROMPT;

        return [
            ['role' => 'system', 'content' => $system],
            ['role' => 'user', 'content' => "Business info:\n" . json_encode($businessAnalysis, JSON_PRETTY_PRINT) . "\n\nPlan:\n" . json_encode($plan, JSON_PRETTY_PRINT)],
        ];
    }
}
