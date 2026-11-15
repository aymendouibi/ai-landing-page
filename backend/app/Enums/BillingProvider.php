<?php

namespace App\Enums;

enum BillingProvider: string
{
    case Stripe = 'stripe';
    case GooglePlay = 'google_play';
    case Manual = 'manual';
    case InApp = 'in_app';
}

