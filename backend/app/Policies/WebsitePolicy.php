<?php

namespace App\Policies;

use App\Models\User;
use App\Models\Website;

class WebsitePolicy
{
    public function view(User $user, Website $website): bool
    {
        return $user->id === $website->project->user_id || $user->isAdmin();
    }

    public function update(User $user, Website $website): bool
    {
        return $user->id === $website->project->user_id || $user->isAdmin();
    }

    public function delete(User $user, Website $website): bool
    {
        return $user->id === $website->project->user_id || $user->isAdmin();
    }
}
