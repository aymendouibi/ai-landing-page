<?php

namespace App\Console\Commands;

use App\Enums\UserRole;
use App\Models\User;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Hash;

class AdminUserCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'admin:user
                            {action : promote|password|create}
                            {email : The email address of the user}
                            {password? : The password (required for password or create)}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Manage administrator accounts (promote, set password, create)';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $action = $this->argument('action');
        $email = $this->argument('email');
        $password = $this->argument('password');

        if ($action === 'promote') {
            $user = User::where('email', $email)->first();
            if (!$user) {
                $this->error("User not found with email: {$email}");
                return 1;
            }
            $user->update(['role' => UserRole::Admin]);
            $this->info("Successfully promoted {$email} to Admin.");
            return 0;
        }

        if ($action === 'password') {
            if (!$password) {
                $password = $this->secret('Enter new password:');
            }
            $user = User::where('email', $email)->first();
            if (!$user) {
                $this->error("User not found with email: {$email}");
                return 1;
            }
            $user->update(['password' => Hash::make($password)]);
            $this->info("Successfully updated password for {$email}.");
            return 0;
        }

        if ($action === 'create') {
            if (!$password) {
                $password = $this->secret('Enter password:');
            }
            $user = User::firstOrCreate(
                ['email' => $email],
                [
                    'name' => 'Administrator',
                    'password' => Hash::make($password),
                    'role' => UserRole::Admin,
                    'email_verified_at' => now(),
                ]
            );
            $user->update([
                'password' => Hash::make($password),
                'role' => UserRole::Admin,
            ]);
            $this->info("Successfully created/updated admin user: {$email}");
            return 0;
        }

        $this->error("Unknown action: {$action}. Use promote, password, or create.");
        return 1;
    }
}
