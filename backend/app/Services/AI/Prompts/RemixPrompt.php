<?php

namespace App\Services\AI\Prompts;

class RemixPrompt
{
    /**
     * @param array<string, mixed> $templateDocument
     * @param array<string, mixed> $businessInfo
     * @param string|null $goal
     * @return array<array{role: string, content: string}>
     */
    public static function build(array $templateDocument, array $businessInfo, ?string $goal = null): array
    {
        $system = <<<PROMPT
You are an expert creative director specializing in "AI Remix".
Your objective is to adapt the provided professional template for a specific business.
PRESERVE the template's layout hierarchy, section order, and component variants.
ADAPT:
1. Site name, branding colors (harmonious palette matching the business), and typography style.
2. Headlines, subheadlines, feature titles, descriptions, FAQs, and calls to action.
3. Keep all component IDs stable.

Respond with pure JSON containing the full adapted website document matching the schema version 1.
PROMPT;

        $userPrompt = "Business Information:\n" . json_encode($businessInfo, JSON_PRETTY_PRINT);
        if ($goal) {
            $userPrompt .= "\nRemix Goal: {$goal} (e.g. adapt to business, improve conversion, make more premium, simplify)\n";
        }
        $userPrompt .= "\nSource Template Document:\n" . json_encode($templateDocument, JSON_PRETTY_PRINT);

        return [
            ['role' => 'system', 'content' => $system],
            ['role' => 'user', 'content' => $userPrompt],
        ];
    }
}
