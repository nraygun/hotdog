# Hotdog!

This is the functional specification for the game that includes gameplay, decision points, and other core pieces of information. Original concept by John Keller.

## Project goal
The goal of the project is to make a game for the 7800 based around the premise that hot dog has to be built with the proper ratio of ingredients, avoiding ketchup at all costs.

## Contributors
- John Keller
- Manny Flores
- Thomas Rogers

## License
GNU GENERAL PUBLIC LICENSE Version 3

Not sure if this is the right one.

## AtariAge forum post
https://forums.atariage.com/topic/388087-introduction/

This link contains the original description of the game and initial discussion.

## Platform:
Atari 7800

## Language:
7800 Basic

## Game resource specifications
- 48K
- No bank switching
- Avoid scrolling backgrounds, which are more tricky
- The 7800 doesn't have collision detection APIs so we'll have to code our own sprite overlap algorithm
## Gameplay

From John(in addition to the info in the "Project goal" section): One thing I was thinking is is that maybe not so much of an order of ingredients but rather the amount of ingredients you get applied. Maybe as you pick up more ingredients the hotdog gets heavier, and therefore is moving slower and therefore is more susceptible to being killed or whatever.
One example that I was thinking of was if it was a “fast food “style game where things are coming horizontally across the screen, one of the things would be splashes of ketchup coming towards them., Which would be sort of like the purple pickles in the fast food game. I know this isn’t the most original idea either.
So one thing I was thinking about is that if you get too much of an ingredient on that that could be a detriment, like imagine you get you pick up too much celery, salt, but you’re not getting the other ingredients. So the strategy would be as you’re picking up other ingredients either a you can pick up too much of one ingredient or be you are getting heavier and slower as you pick up additional ingredients therefore impeding your gain performance and putting you a greater risk of being killed. So you kind of wanna be fairly light and nimble until you get all of the ingredients to pass that level.

The other thing that would be kind of cool to do with this game is to have a couple different levels where the action is a little bit different. Definitely need to get one gameplay down first and then it could be alternate levels.

Proposal from Manny: We could have a ketchup bottle bounce around the screen while the player(the bun?) tries to catch the other ingredients in order. If you touch the ketchup, lose a life. Not sure what would happen if you touch an ingredient that is out of order(like touching mustard before the frank). Maybe remove the last ingredient and spawn it in some other random space in the playing field.
And then the playfield could represent a hotdog stand(Jim's Original, Demon Dogs, etc.) with different obstacles that the player has to maneuver around to get to the ingredients while avoiding the ketchup.

## Questions/Open Issues

### 1. Verticle or horizontal?

### 2. Do you control the hot dog or the person dispensing the ingredients?

### 3. What’s the best way to prepare Sprite graphics? GIMP or sprite editor in Atari Dev studio? Recommends use of the GIMP program, which is like an open source free version or donationware version of Adobe Photoshop for graphics/sprite creation (palette control)?

Manny - I vote we use the sprite editor within ADS

### 4. What are the best sample codes and tutorials that already exist on the Atari age forums?

### 5. What’s the best practice for starting a brand new project? Coding first and optimize graphics later? Are there a kernel concerns like that in the 2600 coding?

Manny - I vote we document the specs of the game first.

### 6. How to do background graphics?

### 7. How to do music?

### 8. How to add some simple Atari Vox additions (for later concern, or does this have to be accounted for in the original build out, for example)

### 9. Recommend the use of a tile program, which I have to still figure out.
https://7800.8bitdev.org/index.php/Sprites_As_Tiles_On_The_7800

## Resources

### Traditional Chicago Hotdog ingredients
- All-beef frankfurter (traditionally Vienna Beef, a kosher-style dog)
- Poppy seed bun
- Yellow mustard
- Bright green sweet pickle relish (often called "Chicago-style relish")
- Chopped white onion
- Tomato slices or wedges
- Kosher dill pickle spear
- Pickled sport peppers (a variety of Capsicum annuum; often substituted with pepperoncini)
- Celery salt (a dash)

Absolutely no ketchup!

From Dauber:
I seriously, honestly will tell you that NOWHERE where the hot dog is considered a delicacy -- literally around the world -- will they put ketchup on a hot dog. I think maybe somewhere in Vietnam and maybe somewhere within Africa their "specialty" hot dog does include ketchup, but nowhere else. Not LA, not New York, not the Southwest, not Texas, not Montreal, not Kansas City, not Rhode Island (they actually have a sign in the New York Station places there saying that ketchup on a hot dog is illegal), etc. I think it's just that we in Chicago are the loudest about it. And there is a scientific reason for it: the sugar content of ketchup reduces the flavor of the hot dog rather than enhance it; on a good all-beef hot dog (Vienna Beef being the best, of course), you want something that will enhance the flavor, like...mustard. And even then, you have to be careful with mustard: avoid French's because the turmeric will also destroy the flavor of the hot dog, and avoid Heinz because it's too vinegary; a good yellow mustard for a hot dog is Plochman's, based out of Manteno. (Also, assuming you "drag it through the garden," ketchup would be redundant with the tomato slices.) The reason people put ketchup on hot dogs in the first place: literally habit from toddlerhood. What's something parents would do to get their fussy rugrats to eat something? Put ketchup on it. And they just don't lose that habit.

### Links

7800 Basics Lessons: https://intotheverticalblank.com/2025/07/02/atari-7800-basic-lessons-1-3/

7800 Basic Guide: https://www.randomterrain.com/7800basic.html

Controls: https://www.randomterrain.com/7800basic.html#controls

7800 Basic Lessons on Youtube: https://youtu.be/UOckFmgrzWc?si=xw3X31sp3o1dyBkh

Markdown language: https://www.markdownguide.org/basic-syntax/

7800 Emulator: https://7800.8bitdev.org/index.php/A7800_Emulator

Atari Dev Studio for Visual Studio Code: https://forums.atariage.com/topic/290365-atari-dev-studio-for-homebrew-development-release/

Github basics: https://www.youtube.com/watch?v=i_23KUAEtUM

