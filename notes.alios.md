alios

**~/Library before enabling Drafts iCloud Sync (no 'Mobile Documents' Folder)**

```bash
mini:~ mobile$ cd Library/
mini:~/Library mobile$ ls
Accounts/              CallHistoryTransactions/  Health/                  Passes/             adi/
AddressBook/           Carrier\ Bundles/         HomeConfiguration/       Preferences/        com.apple.Music/
AggregateDictionary/   ConfigurationProfiles/    IdentityServices/        SMS/                com.apple.iTunesStore/
ApplePushService/      Cookies/                  Keyboard/                Safari/             com.apple.itunesstored/
Application\ Support/  CoreDuet/                 Logs/                    Social/             com.apple.nsurlsessiond/
Assets/                CrashReporter/            Mail/                    SoftwareUpdate/     com.apple.printd/
Assistant/             Cydia/                    MediaStream/             Spotlight/          fps/
BackBoard/             DataAccess/               MobileBluetooth/         SpringBoard/        homed/
BatteryLife/           FairPlay/                 MobileContainerManager/  SyncedPreferences/  mad/
BulletinBoard/         FileProvider/             MobileInstallation/      TCC/
Caches/                Filza/                    MusicLibrary/            VoiceServices/
Calendar/              GameKit/                  Notes/                   Voicemail/
CallHistoryDB/         GeoServices/              OTALogging/              WebClips/
```

**~/Library before enabling Drafts iCloud Sync ( autocreated 'Mobile Documents' )**

```bash
mini:~/Library mobile$ ls
Accounts             Assets         Caches                   ConfigurationProfiles  DataAccess    GeoServices        Logs              MobileContainerManager  Passes       SoftwareUpdate     VoiceServices    com.apple.iTunesStore    homed
AddressBook          Assistant      Calendar                 Cookies                FairPlay      Health             Mail              MobileInstallation      Preferences  Spotlight          Voicemail        com.apple.itunesstored   mad
AggregateDictionary  BackBoard      CallHistoryDB            CoreDuet               FileProvider  HomeConfiguration  MediaStream       MusicLibrary            SMS          SpringBoard        WebClips         com.apple.nsurlsessiond
ApplePushService     BatteryLife    CallHistoryTransactions  CrashReporter          Filza         IdentityServices   **Mobile Documents**  Notes                   Safari       SyncedPreferences  adi              com.apple.printd
Application Support  BulletinBoard  Carrier Bundles          Cydia                  GameKit       Keyboard           MobileBluetooth   OTALogging              Social       TCC                com.apple.Music  fps
```

**use TextEdit dir in Mobile\ Documents as alios cloud storage**
```bash
mini:~/Library/Mobile Documents/com~apple~TextEdit/Documents mobile$
```




