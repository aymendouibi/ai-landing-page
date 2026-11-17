<?php

namespace App\Services;

use App\Enums\WebsiteStatus;
use App\Models\AppNotification;
use App\Models\User;
use App\Models\Website;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Log;

class NotificationService
{
    /**
     * Supported notification locales.
     */
    public const SUPPORTED_LOCALES = ['en', 'es', 'fr', 'de', 'ar', 'zh', 'ja', 'pt'];

    /**
     * Multilingual translation dictionary for system notifications.
     */
    protected static array $messages = [
        'ai_modification' => [
            'en' => [
                'title' => 'AI Modification Finished ✨',
                'body' => "Your changes for ':site_name' have been generated and applied successfully.",
            ],
            'fr' => [
                'title' => 'Modification IA terminée ✨',
                'body' => "Vos modifications pour ':site_name' ont été appliquées avec succès.",
            ],
            'es' => [
                'title' => 'Modificación de IA completada ✨',
                'body' => "Tus cambios para ':site_name' se han aplicado con éxito.",
            ],
            'de' => [
                'title' => 'KI-Änderung abgeschlossen ✨',
                'body' => "Deine Änderungen für ':site_name' wurden erfolgreich übernommen.",
            ],
            'ar' => [
                'title' => 'اكتمل تعديل الذكاء الاصطناعي ✨',
                'body' => "تم تطبيق التعديلات على ':site_name' بنجاح.",
            ],
            'zh' => [
                'title' => 'AI 修改已完成 ✨',
                'body' => "您对“:site_name”的修改已成功应用。",
            ],
            'ja' => [
                'title' => 'AIの修正が完了しました ✨',
                'body' => "「:site_name」への変更が正常に適用されました。",
            ],
            'pt' => [
                'title' => 'Modificação de IA concluída ✨',
                'body' => "Suas alterações para ':site_name' foram aplicadas com sucesso.",
            ],
        ],
        'site_live' => [
            'en' => [
                'title' => 'Website is Live! 🚀',
                'body' => "Your website ':site_name' is now live and published on the web.",
            ],
            'fr' => [
                'title' => 'Votre site est en ligne ! 🚀',
                'body' => "Votre site web ':site_name' est maintenant publié et accessible.",
            ],
            'es' => [
                'title' => '¡Tu sitio web está en línea! 🚀',
                'body' => "Tu sitio web ':site_name' ya está publicado y disponible en la web.",
            ],
            'de' => [
                'title' => 'Website ist online! 🚀',
                'body' => "Deine Website ':site_name' ist jetzt live und im Web erreichbar.",
            ],
            'ar' => [
                'title' => 'موقعك متاح الآن! 🚀',
                'body' => "تم نشر موقعك ':site_name' بنجاح وهو متاح الآن على الويب.",
            ],
            'zh' => [
                'title' => '网站已上线！🚀',
                'body' => "您的网站“:site_name”现已公开发布在互联网上。",
            ],
            'ja' => [
                'title' => 'Webサイトが公開されました！🚀',
                'body' => "Webサイト「:site_name」が正常に公開され、アクセス可能になりました。",
            ],
            'pt' => [
                'title' => 'Seu site está no ar! 🚀',
                'body' => "Seu site ':site_name' já está publicado e disponível na web.",
            ],
        ],
        'draft_reminder' => [
            'en' => [
                'title' => 'Complete your website 📝',
                'body' => "Don't forget to complete your website ':site_name'! Your draft is almost ready to go live.",
            ],
            'fr' => [
                'title' => 'Terminez votre site web 📝',
                'body' => "N'oubliez pas de terminer votre site ':site_name' ! Votre brouillon est presque prêt à être mis en ligne.",
            ],
            'es' => [
                'title' => 'Completa tu sitio web 📝',
                'body' => "¡No olvides completar tu sitio web ':site_name'! Tu borrador está casi listo para publicarse.",
            ],
            'de' => [
                'title' => 'Website fertigstellen 📝',
                'body' => "Vergiss nicht, deine Website ':site_name' fertigzustellen! Dein Entwurf ist fast bereit zur Veröffentlichung.",
            ],
            'ar' => [
                'title' => 'أكمل موقعك الإلكتروني 📝',
                'body' => "لا تنسَ إكمال موقعك الإلكتروني ':site_name'! مسودتك جاهزة تقريبًا للنشر.",
            ],
            'zh' => [
                'title' => '完成您的网站 📝',
                'body' => "别忘了完成您的网站“:site_name”！您的草稿即将准备就绪。",
            ],
            'ja' => [
                'title' => 'Webサイトを完成させましょう 📝',
                'body' => "Webサイト「:site_name」の作成を完了させましょう！下書きの公開準備はほぼ整っています。",
            ],
            'pt' => [
                'title' => 'Conclua seu site 📝',
                'body' => "Não se esqueça de concluir seu site ':site_name'! Seu rascunho está quase pronto para ser publicado.",
            ],
        ],
    ];

    /**
     * Resolve the target locale for a user.
     */
    public function resolveUserLocale(?User $user, ?string $fallback = null): string
    {
        if ($fallback && in_array(strtolower($fallback), self::SUPPORTED_LOCALES, true)) {
            return strtolower($fallback);
        }

        if ($user && !empty($user->preferences['locale'])) {
            $lang = strtolower(substr($user->preferences['locale'], 0, 2));
            if (in_array($lang, self::SUPPORTED_LOCALES, true)) {
                return $lang;
            }
        }

        $headerLocale = request()?->header('X-App-Locale');
        if ($headerLocale) {
            $lang = strtolower(substr($headerLocale, 0, 2));
            if (in_array($lang, self::SUPPORTED_LOCALES, true)) {
                return $lang;
            }
        }

        return 'en';
    }

    /**
     * Get translated message for a notification key.
     */
    public function getMessage(string $type, string $locale, array $replacements = []): array
    {
        $lang = in_array($locale, self::SUPPORTED_LOCALES, true) ? $locale : 'en';
        $template = self::$messages[$type][$lang] ?? self::$messages[$type]['en'] ?? [
            'title' => 'Notification',
            'body' => '',
        ];

        $title = $template['title'];
        $body = $template['body'];

        foreach ($replacements as $key => $val) {
            $title = str_replace(":{$key}", (string) $val, $title);
            $body = str_replace(":{$key}", (string) $val, $body);
        }

        return ['title' => $title, 'body' => $body];
    }

    /**
     * Send notification when AI finishes a modification.
     */
    public function sendAiModification(User $user, Website $website, ?string $summary = null): AppNotification
    {
        $locale = $this->resolveUserLocale($user);
        $siteName = $website->name ?? $website->document['meta']['name'] ?? 'Your Website';
        $msg = $this->getMessage('ai_modification', $locale, ['site_name' => $siteName]);

        $body = $msg['body'];
        if (!empty($summary) && $summary !== "AI Edit: ") {
            $body .= " ({$summary})";
        }

        return AppNotification::create([
            'user_id' => $user->id,
            'type' => 'ai_modification',
            'title' => $msg['title'],
            'body' => $body,
            'locale' => $locale,
            'data' => [
                'website_id' => $website->id,
                'site_name' => $siteName,
                'summary' => $summary,
                'action' => 'open_editor',
            ],
        ]);
    }

    /**
     * Send notification when site is live.
     */
    public function sendSiteLive(User $user, Website $website, string $url): AppNotification
    {
        $locale = $this->resolveUserLocale($user);
        $siteName = $website->name ?? $website->document['meta']['name'] ?? 'Your Website';
        $msg = $this->getMessage('site_live', $locale, ['site_name' => $siteName]);

        return AppNotification::create([
            'user_id' => $user->id,
            'type' => 'site_live',
            'title' => $msg['title'],
            'body' => $msg['body'],
            'locale' => $locale,
            'data' => [
                'website_id' => $website->id,
                'site_name' => $siteName,
                'url' => $url,
                'action' => 'open_live_site',
            ],
        ]);
    }

    /**
     * Send draft reminder notification with website name.
     */
    public function sendDraftReminder(User $user, Website $website): AppNotification
    {
        $locale = $this->resolveUserLocale($user);
        $siteName = $website->name ?? $website->document['meta']['name'] ?? 'Untitled Site';
        $msg = $this->getMessage('draft_reminder', $locale, ['site_name' => $siteName]);

        return AppNotification::create([
            'user_id' => $user->id,
            'type' => 'draft_reminder',
            'title' => $msg['title'],
            'body' => $msg['body'],
            'locale' => $locale,
            'data' => [
                'website_id' => $website->id,
                'site_name' => $siteName,
                'action' => 'open_editor',
            ],
        ]);
    }

    /**
     * Send notification from Admin Dashboard.
     * Can target all users, a specific user, or users with draft websites.
     */
    public function sendAdminNotification(
        string $title,
        string $body,
        ?string $targetUserId = null,
        ?string $url = null,
        ?string $locale = null,
        ?string $type = 'admin_broadcast'
    ): Collection {
        $created = collect();

        if (!empty($targetUserId)) {
            $user = User::find($targetUserId);
            if ($user) {
                $userLocale = $locale ?: $this->resolveUserLocale($user);
                $notif = AppNotification::create([
                    'user_id' => $user->id,
                    'type' => $type ?: 'admin_broadcast',
                    'title' => $title,
                    'body' => $body,
                    'locale' => $userLocale,
                    'data' => [
                        'url' => $url,
                        'sent_by' => 'admin',
                        'action' => $url ? 'open_url' : 'view',
                    ],
                ]);
                $created->push($notif);
            }
            return $created;
        }

        // Broadcast to all active users
        User::query()->chunk(100, function ($users) use ($title, $body, $url, $locale, $type, &$created) {
            foreach ($users as $user) {
                $userLocale = $locale ?: $this->resolveUserLocale($user);
                $notif = AppNotification::create([
                    'user_id' => $user->id,
                    'type' => $type ?: 'admin_broadcast',
                    'title' => $title,
                    'body' => $body,
                    'locale' => $userLocale,
                    'data' => [
                        'url' => $url,
                        'sent_by' => 'admin',
                        'action' => $url ? 'open_url' : 'view',
                    ],
                ]);
                $created->push($notif);
            }
        });

        return $created;
    }

    /**
     * Send draft reminders to users who have unfinished drafts.
     * Prevents spamming: only sends if no reminder was sent in the last 24h.
     */
    public function sendDraftRemindersToAll(int $hoursThreshold = 1): int
    {
        $draftWebsites = Website::where('status', WebsiteStatus::Draft)
            ->whereNotNull('project_id')
            ->where('updated_at', '<=', now()->subHours($hoursThreshold))
            ->with(['project.user'])
            ->get();

        $count = 0;
        $processedUserIds = [];

        foreach ($draftWebsites as $website) {
            $user = $website->project?->user;
            if (!$user || in_array($user->id, $processedUserIds, true)) {
                continue;
            }

            // Check if reminder was sent in the last 24 hours
            $recentReminder = AppNotification::where('user_id', $user->id)
                ->where('type', 'draft_reminder')
                ->where('created_at', '>=', now()->subHours(24))
                ->exists();

            if ($recentReminder) {
                continue;
            }

            $this->sendDraftReminder($user, $website);
            $processedUserIds[] = $user->id;
            $count++;
        }

        Log::info("Draft reminder notifications sent to {$count} users.");
        return $count;
    }
}
