# Profiles and saves

[← Documentation](../README.md)

Each **profile** has its own saves (which can hold several characters), backups and trophies.
Stop the game before changing profiles or managing saves.

## Your first profile

The first time you open the launcher (or after updating from a version without profiles), it
asks for a profile name. Your existing saves stay where they are and belong to this profile.
Play is available once the profile is created.

## Profiles

- **New profile** (top of the Profiles tab): a new profile starts with no saves.
- **Use profile**, or the **Active profile** selector above Play, chooses which one Play uses.
- Renaming a profile changes only its name.
- **Delete** removes an inactive profile with its saves and backups, after a confirmation. The
  active profile and the last one cannot be deleted.

Click a profile's name to open its **Saves · Backups** and **Trophies**; opening a profile does
not make it the active one.

## Saves and backups

Saves · Backups shows the save's size and date, and its backups.

- A backup is made automatically **before every launch**. **Back up** makes another.
- **Restore** (then confirm) replaces the save with a backup; the current save is backed up first.
- **Show in Finder** opens the save or backup folder. Backups are kept until you delete them.

The Saves page also previews each readable character's name, level, attributes, Blood Echoes,
Insight, playtime and journey. **Edit character** changes Vitality (7–99), Endurance (8–99)
and the other four attributes (1–99),
Blood Echoes (up to 999,999,999) and Insight (up to 99). **Max all** sets them to their maxima,
reaching level 544. Level follows the attributes; changing Vitality or Endurance also sets
the saved health or stamina to its full base value. Runes and equipment may alter the value
shown in game. The game must be stopped. Confirming an edit first backs up
the complete current save set, then marks the edited save as ineligible for new trophies. To
continue from a clean save, restore a backup from before the first edit.

## Trophies

Trophies you earn are recorded on your Mac for the active profile (nothing is sent to PSN). The
Trophies page lists all 40, Bloodborne and The Old Hunters separately, with grades, short
requirements and the date you earned each. Platinum comes after the other 33 base-game trophies.
Trophies earned before this tracking existed are not imported from a save.

**Edited saves cannot earn trophies.** A save marked as edited shows a warning; trophies earned
before stay. Restoring a backup from before the edit restores eligibility.

## Where it is stored

In `~/Library/Application Support/bloodborne_mac/`:

| Path | Contents |
|---|---|
| `launcher.db` | Profiles, settings, backup records and trophies |
| `user/` | Your first profile's saves, and the shader cache all profiles share |
| `save-profiles/<id>/user/` | Other profiles' saves |
| `save-backups/<id>/` | Backups |
| `database-backups/` | Copies of `launcher.db` made before launcher updates changed it |

## If profiles cannot load

The launcher shows the error with **Retry** and **Show in Finder**. Free disk space, fix
permissions or close another launcher, then retry. If it says the database is from a newer
launcher, install the latest version.

**Do not delete `launcher.db`** to get past an error: your profiles, which saves are whose, and
your trophies are kept there. Quit the launcher, copy the whole data folder (including
`launcher.db-wal` and `launcher.db-shm`), and
[report the message](https://github.com/bloodborne-native/bloodborne-mac/issues).
