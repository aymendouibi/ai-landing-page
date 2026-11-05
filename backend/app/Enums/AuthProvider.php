<?php

namespace App\Enums;

enum AuthProvider: string
{
    case Email = 'email';
    case Google = 'google';
    case Apple = 'apple';
}
