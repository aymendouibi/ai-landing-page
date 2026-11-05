<?php

namespace App\Enums;

enum RevisionSource: string
{
    case Manual = 'manual';
    case AiGenerate = 'ai_generate';
    case AiEdit = 'ai_edit';
    case AiRemix = 'ai_remix';
    case Import = 'import';
    case Restore = 'restore';
}

