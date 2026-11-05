<?php

namespace App\Enums;

enum DeploymentStatus: string
{
    case Pending = 'pending';
    case Building = 'building';
    case Deploying = 'deploying';
    case Deployed = 'deployed';
    case Failed = 'failed';
    case RolledBack = 'rolled_back';
}

