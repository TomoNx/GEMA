<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Create test guide user
        User::firstOrCreate(
            ['email' => 'guide@gema.test'],
            [
                'name' => 'Guide Test',
                'password' => bcrypt('password'),
                'email_verified_at' => now(),
            ]
        );

        // Seed prayers
        $this->call(PrayerSeeder::class);
    }
}
