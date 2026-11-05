<?php

namespace App\Enums;

enum AiJobType: string
{
    case Generate = 'generate';
    case Remix = 'remix';
    case Edit = 'edit';
    case EditComponent = 'edit_component';
    case Plan = 'plan';
    case VisionQa = 'vision_qa';
}
