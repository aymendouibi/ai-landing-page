<?php

namespace App\Console\Commands;

use App\Services\NotificationService;
use Illuminate\Console\Command;

class SendDraftRemindersCommand extends Command
{
    /**
     * The name and signature of the console command.
     */
    protected $signature = 'notifications:remind-drafts {--hours=1 : Hours threshold since draft was last updated}';

    /**
     * The console command description.
     */
    protected $description = 'Send localized push notifications to users reminding them to complete their draft website';

    /**
     * Execute the console command.
     */
    public function handle(NotificationService $notificationService): int
    {
        $hours = (int) $this->option('hours');
        $this->info("Scanning for draft websites inactive for at least {$hours} hour(s)...");

        $sentCount = $notificationService->sendDraftRemindersToAll($hours);

        $this->info("Successfully sent {$sentCount} draft reminder notification(s) in users' selected languages.");

        return Command::SUCCESS;
    }
}
