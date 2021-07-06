# goPlay Social - iOS



## About 

I started goPlay in 2015 as a passion project and exercise in pursuing a small idea into something big. goPlay is at its core, a social networking app. At first glance, it's obvious - photo feed, upvotes, profiles, comments, network of friends. But goPlay has a bit more going on under the hood.

The goal of the goPlay project is to find a way to incentivize average users to engage in outdoor play more often. In some ways it's the anti-social media app. Using social **and financial** (more about this below) incentives to encourage activities **away from the screens**

I learned an incredible amount spear-heading this project. Over the years of its development, I was the sole engineer developing the platform. I leveraged existing frameworks wherever possible, but unique design requires custom solutions. 

**Systems and Tools utilized in this project:**

- MongoDB
- Heroku with Node.js
- Stripe payments
- Google Maps and MapKit
- Graph API
- Social media log-in (Twitter, Facebook, instagram)
- Parse-Server
- Mailgun email verification
- Deep links
- Flurry Analytics
- iCal integration

**Languages utilized with this project:**

- Objective-C
- JavaScript

UI and user flow design by the incomparable [Matthew Cavender](https://www.linkedin.com/in/matthew-cavender-071b5028/)

Check out the [goPlay Social Website](https://www.goplay.social) for more information about the project from a broader vantage point. This page is intended to describe some of the features, and highlight a few classes built along with the project.


## The Feed

Each photo shared to the feed records a real-world **activity**, engaged in by real people at a real location.
The feed featued a semi-transparent sliding info pane for each photo, complete with upvotes, comments, and report capablities.

![AD_Feed_Small](https://user-images.githubusercontent.com/24867725/124678281-0f0e4500-de77-11eb-8e2b-3829e038f663.png)

## Activities
What makes goPlay's "real-world **activity**" different than just sharing a photo on instagram? Well here's where goPlay diverges from typical social networking. Users have two main routes for participating in and activity - **Start** and **Find**

![AD_Activities](https://user-images.githubusercontent.com/24867725/124678298-16355300-de77-11eb-82d2-21b2260534c7.png)

#### Start
Users can start a new activity by filling out some basic information - type/location/time  etc, and invite players within their network. Once the game is over, the game leader can **Lock In** the game, which posts it to the feed for themselves and all players.

#### Find
goPlay leverages Google Maps and Apple's MapKit to allow users to visualy search for activities started by other users in their area. Selecting the detail box directs the user to the activity details.

## Profile and Badges

As users participate in more activities they will automatically earn badges which represent their efforts. This is how goPlay quanitifies the user's participation in a given activity category, and is the heart of the financial incentive structure leverage by the **in-app Marketplace**. Over time, users build up a library of badges representing their unique activity history.

![AD_ProfBadges](https://user-images.githubusercontent.com/24867725/124678306-1df4f780-de77-11eb-962e-446ed69c28a6.png)


## Market


goPlay's in-app market is where it all comes together. Users get access to exclusive product and service deals based on their specific badge ranks. So, play more games, get more (and deeper) deals. This is Groupon + Meet-Up. Users are incentivized to get out of the house, and merchants are happy to give discounts to people who verifiably participate in their target market. Win-win.

![08_MarketAll](https://user-images.githubusercontent.com/24867725/124678350-31a05e00-de77-11eb-838d-32a132481d0a.png)


In its first implementation, I used various affiliate patforms to aggregate the deals. I ran a simple script via Heroku and Node.js to scrape the deals, generate badge requirements, and ingest them into our database. This was a fully automated process.

## Trust Metrics and Sybil Attacks

Of course, any system with financial incentives lends itself to exploitation. Users could fake their activities, spam the feed, and farm discounts. In technical terms, this is: No Bueno.

goPlay is essentially a peer-to-peer system, not unlike blockchain's distributed ledger. But just as with bitcoin, the system is open to attack by malicious nodes in the network. The main difference is that bitcoin is anonymous, where goPlay is anything but. 

So the key was to utlize a set of algorithms weighted by location services and a user's network diversity to assign a **trust value** to each user. Once users pass a certain trust value, they get the all-important **Trusted** badge.

The broader range of users they play games with, the more trusted they are. The more often they use location services to check-in to their games, well you get the idea. You can't use goPlay in total isolation or in a closed island of users and expect to get any discounts. In this kind of system we can reduce the risk of significant attacks without being overly invasive to the user experience.
