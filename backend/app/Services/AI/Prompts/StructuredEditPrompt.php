<?php

namespace App\Services\AI\Prompts;

class StructuredEditPrompt
{
    /**
     * @param array<string, mixed> $currentDocument
     * @param string $instruction
     * @param string|null $targetSectionId
     * @return array<array{role: string, content: string}>
     */
    public static function build(array $currentDocument, string $instruction, ?string $targetSectionId = null): array
    {
        $system = <<<PROMPT
You are a precision website document editor.
Your job is to translate a user's natural language edit instruction into a list of atomic operations on the website document.
Supported operations:
1. "update_component": { "type": "update_component", "section_id": "string", "props": { ... }, "styles": { ... } }
2. "add_component": { "type": "add_component", "page_id": "page_home", "order": 2, "section": { "id": "sec_new_...", "component": "hero|features|...", "variant": "...", "props": { ... } } }
3. "remove_component": { "type": "remove_component", "section_id": "string" }
4. "move_component": { "type": "move_component", "section_id": "string", "new_order": 1 }
5. "update_design_token": { "type": "update_design_token", "path": "colors.primary", "value": "#HEX" }
6. "update_seo": { "type": "update_seo", "page_id": "page_home", "seo": { "title": "...", "description": "..." } }

CRITICAL RULES:
- Target stable IDs existing in the document.
- Only modify requested elements; preserve all unrelated content.
- Never output arbitrary HTML or JavaScript.
- Respond with pure JSON only:
{
  "operations": [
    { ... }
  ],
  "summary": "Brief description of changes made"
}
PROMPT;

        $userPrompt = "User Instruction: {$instruction}\n";
        if ($targetSectionId) {
            $userPrompt .= "Target Section ID: {$targetSectionId}\n";
        }
        $userPrompt .= "\nCurrent Website Document:\n" . json_encode($currentDocument, JSON_PRETTY_PRINT);

        return [
            ['role' => 'system', 'content' => $system],
            ['role' => 'user', 'content' => $userPrompt],
        ];
    }
}

