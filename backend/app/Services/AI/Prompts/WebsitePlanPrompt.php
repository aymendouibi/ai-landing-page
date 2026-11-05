<?php

namespace App\Services\AI\Prompts;

class WebsitePlanPrompt
{
    /**
     * @param array<string, mixed> $businessAnalysis
     * @return array<array{role: string, content: string}>
     */
    public static function build(array $businessAnalysis): array
    {
        $system = <<<PROMPT
You are an expert website architect and conversion strategist.
Plan the section structure for the website.
IMPORTANT: You MUST ONLY select components from this approved list:
- "hero" (variants: "centered", "split_image", "minimal")
- "features" (variants: "grid_3col", "icon_cards", "two_column")
- "about" (variants: "split_image", "full_width")
- "statistics" (variants: "cards", "inline")
- "testimonials" (variants: "cards", "grid")
- "faq" (variants: "accordion")
- "cta" (variants: "centered", "banner")
- "contact" (variants: "form_split", "info_only")
- "footer" (variants: "simple", "multi_column")

NEVER invent unsupported component types.
Respond with pure JSON only matching this schema:
{
  "navigation_items": [
    { "label": "string", "href": "string", "type": "link | button" }
  ],
  "sections": [
    {
      "component": "hero | features | about | statistics | testimonials | faq | cta | contact | footer",
      "variant": "string",
      "purpose": "string",
      "background": "default | surface"
    }
  ]
}
PROMPT;

        return [
            ['role' => 'system', 'content' => $system],
            ['role' => 'user', 'content' => "Plan website for:\n" . json_encode($businessAnalysis, JSON_PRETTY_PRINT)],
        ];
    }
}
