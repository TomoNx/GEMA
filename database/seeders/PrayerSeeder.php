<?php

namespace Database\Seeders;

use App\Models\Prayer;
use Illuminate\Database\Seeder;

class PrayerSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $prayers = [
            [
                'title' => 'Doa Masuk Masjidil Haram',
                'content' => "بِسْمِ اللهِ وَالصَّلاَةُ وَالسَّلاَمُ عَلَى رَسُوْلِ اللهِ، اَللّٰهُمَّ افْتَحْ لِيْ أَبْوَابَ رَحْمَتِكَ\n\nArtinya: Dengan nama Allah, shalawat dan salam semoga tercurah kepada Rasulullah. Ya Allah, bukakanlah untukku pintu-pintu rahmat-Mu.",
            ],
            [
                'title' => 'Doa Tawaf',
                'content' => "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ\n\nArtinya: Ya Tuhan kami, berilah kami kebaikan di dunia dan kebaikan di akhirat, dan lindungilah kami dari azab neraka.",
            ],
            [
                'title' => 'Doa Sa\'i',
                'content' => "إِنَّ الصَّفَا وَالْمَرْوَةَ مِنْ شَعَائِرِ اللهِ\n\nArtinya: Sesungguhnya Shafa dan Marwah adalah sebagian dari syi'ar Allah.",
            ],
            [
                'title' => 'Doa Minum Air Zamzam',
                'content' => "اَللّٰهُمَّ إِنِّيْ أَسْأَلُكَ عِلْمًا نَافِعًا وَرِزْقًا وَاسِعًا وَشِفَاءً مِنْ كُلِّ دَاءٍ\n\nArtinya: Ya Allah, aku memohon kepada-Mu ilmu yang bermanfaat, rezeki yang luas, dan kesembuhan dari segala penyakit.",
            ],
            [
                'title' => 'Doa di Multazam',
                'content' => "اَللّٰهُمَّ يَا رَبَّ الْبَيْتِ الْعَتِيْقِ، أَعْتِقْ رِقَابَنَا وَرِقَابَ آبَائِنَا وَأُمَّهَاتِنَا وَإِخْوَانِنَا وَأَوْلاَدِنَا مِنَ النَّارِ\n\nArtinya: Ya Allah, Tuhan pemilik Baitullah yang mulia, bebaskanlah diri kami, ayah-ibu kami, saudara-saudara kami, dan anak-anak kami dari api neraka.",
            ],
        ];

        foreach ($prayers as $prayer) {
            Prayer::firstOrCreate(['title' => $prayer['title']], $prayer);
        }
    }
}
