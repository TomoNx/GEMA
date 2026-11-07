<?php

namespace App\Services;

use Agence104\LiveKit\AccessToken;
use Agence104\LiveKit\AccessTokenOptions;
use Agence104\LiveKit\VideoGrant;
use Agence104\LiveKit\RoomServiceClient;

class LiveKitService
{
    private string $apiKey;
    private string $apiSecret;
    private string $host;

    public function __construct()
    {
        $this->apiKey = (string) (config('services.livekit.api_key') ?: 'gema_dev_key');
        $this->apiSecret = (string) (config('services.livekit.api_secret') ?: 'gema_dev_secret_key_at_least_32_bytes_long!!');
        $this->host = (string) (config('services.livekit.host') ?: 'https://dummy.livekit.cloud');
    }

    /**
     * Generate access token for a participant
     */
    public function generateToken(
        string $roomName,
        string $identity,
        bool $canPublish = true,
        bool $canSubscribe = true,
        bool $isAdmin = false
    ): string {
        $videoGrant = new VideoGrant();
        $videoGrant->setRoomJoin(true);
        $videoGrant->setRoomName($roomName);
        $videoGrant->setCanPublish($canPublish);
        $videoGrant->setCanSubscribe($canSubscribe);

        if ($isAdmin) {
            $videoGrant->setRoomAdmin(true);
        }

        $tokenOptions = (new AccessTokenOptions())
            ->setIdentity($identity)
            ->setTtl(6 * 60 * 60); // 6 hours

        $token = new AccessToken($this->apiKey, $this->apiSecret);
        $token->init($tokenOptions)->setGrant($videoGrant);

        return $token->toJwt();
    }

    /**
     * Generate token for guide (admin privileges)
     */
    public function generateGuideToken(string $roomSlug, string $guideIdentity): string
    {
        return $this->generateToken(
            roomName: $roomSlug,
            identity: $guideIdentity,
            canPublish: true,
            canSubscribe: true,
            isAdmin: true
        );
    }

    /**
     * Generate token for pilgrim
     */
    public function generatePilgrimToken(string $roomSlug, string $pilgrimId): string
    {
        return $this->generateToken(
            roomName: $roomSlug,
            identity: $pilgrimId,
            canPublish: true,
            canSubscribe: true,
            isAdmin: false
        );
    }

    /**
     * Get RoomServiceClient for server-side room management
     */
    public function getRoomServiceClient(): RoomServiceClient
    {
        return new RoomServiceClient($this->host, $this->apiKey, $this->apiSecret);
    }
}
