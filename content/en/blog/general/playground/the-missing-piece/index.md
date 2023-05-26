---
date: 2022-07-08
title: "Kyverno Playground - The missing piece"
linkTitle: "Kyverno Playground - The missing piece"
description: "Announcing the Kyverno Playground"
---

![kyverno](kyverno.png)

A couple weeks ago, the first alpha version of the [Kyverno Playground](https://playground.kyverno.io) was publicly released.

This is the story of a totally unexpected project that came out from nowhere but finally made it in just a few days :tada:.

I think the Playground is one of the most wanted and oldest feature request.

Since the beginning of Kyverno, we were regularly asked if we had plans to create an interactive website to play with Kyverno directly from a browser. Users wanted to experiment without the burden of spinning up a cluster, installing the CLi and write some yaml files, dig out the [policies catalog](https://kyverno.io/policies) to find policies to test, etc...

While the feature request was legitimate, we never found the time to think about it more than a few minutes and the challenge to create such a project seemed pretty high, there was always more high priority things to do.

This was until we came back from KubeCon EU in Amsterdam !

It was my first KubeCon and i had the chance to meet in real life with part of the Kyverno team, Jim Bugwadia (, )creator of Kyverno and co-founder of Nirmata, incidentally he is also my boss), and Frank (long time Kyverno maintainer and creator or the policy reporter and other projects, he's the man behind falco sidekick for example, just that).

Of course we met a lot of users and had a booth in the CNCF community area.

Just as other booths we had a TV screen continuously rotating powerpoint slides that Jim conscientiously prepared for the conference.
This was great but not exactly interactive and users that came to the booth wanted to know more about Kyverno and eventually try it.

If you ask me, I think Kyverno is the kind of thing hard to explain on paper but when you play with it you understand it almost instantly, and with a bit of help you can achieve impressive things in just a couple of minutes.

What if a user came to the booth to understand how Kyverno can help migrate from PSPs and never tried Kyverno before ? It would take us a long time to explain the what, how and why to him.

Now let's take this user, bring him an interactive Playground, click on the PSP preset to load relevant policies and resources and click the `Play` button, he's got the answer he was looking for in a fun and interactive way. He can even play with it at home or while waiting his plane to fly back home :).


At this point, there was no doubt that such a tool was needed. I think Jim and Frank talked about it during the conference, then the conference went over and we all traveled back home.

The story could have stopped here without Frank posting a quick innocent message on slack a few days laters, in the spirit of `Do we have json schemas to validate Kyverno policies ?`.

It was not hard to guess what Frank had in mind, the Playground was running around in his brain, he probably had already picutred the UI in his head and was looking for a solution to validate and support autocomplete in policies editor.

I can't really explain why this caught our attention more than other things but we engaged the conversation pretty quickly, at the time i was contributing to kubectl-validate, another project that works a lot with openapi schemas to validate resources offline as precisely as possible.

The plan was to take openapi schemas and convert them to json schemas, Frank could then use these schemas in his policies editor. From that simple discussion, we created a GitHub repository and I pushed the openapi schemas. The Playground repository was born.

After just a few hours, Frank pushed the first version of the UI, he went incredibly fast, so fast that I suspect he started working on it in secret before telling us :P

We had the frontend, we needed a backend !

That's when i paired with Frank and decided to see what it would take to run the Kyverno engine completely outside a cluster and simulate how as close as possible how the admission controller works.

Our CLI code has a lot of legacy and we heavily refactored the Kyverno engine in 1.10. For these reasons it made sense to start from scratch and not reuse the CLI code.

A few hours later, we had a simple api implemented with gin that was able to take an arbitrary number of resources and policies, invoke the kyverno engine to evaluate every policy against every resource and return engine responses in json format to the frontend.

It was fairly simple at this time, we supported only validation policies and only a subset of the Kyverno features were available... but it was just a few hours of work and we had most of the components in place (well, at least we had a frontend and a backend).

And that's what happens when you play with matches, it caused a fires. In the next hours Frank created the UI to display engine responses, we added support for mutating, generation and other policy rules.

We added support for image verification rules, we allowed mocking variables, improved resources and policies decoding to work as closely as possible as an api server admission review pipeline. Frank improved the UI to show changes that occured in mutating rules and so on.

From what i remember it took just 3 or 4 days to get the Playground features on par with the CLI features !

Chip Zoller then jumped in and helped us structure the project, he fixed most of the typos, suggested great enhancements like adding an interactive tutorial, how to improve UI/UX.

With all the suggestions from Chip, we create the `v0.1.0` milestone and Frank and Chip started to address issues one by one.

The challenge was high but we were confident that it would give us a solid alpha version if we could get those suggestions done.

It probably took 2 or 3 more days to get the milestone issues dry !

The first milestone completed, it was time to think about cutting a release.

We created an Helm chart and kindly asked if Nirmata could provide a small cluster to host the Playground.
We received the cluster from Nirmata one day later... but it was too late, we were so impatient to get it out in the wild, and Frank already had it deployed on his personal cluster (anyway, thanks Nirmata for providing the infrastructure, for sure next versions will run there) !

Chip then added the DNS record to point https://playground.kyverno.io to the Frank's cluster and announced the Playground release on Slack !

This was an incredible ride, taking the Playground from nothing to an alpha version released to the public in less than 10 days was a blast. This doesn' happen often to have this chance to turn an idea into something concrete.

Since then, we released `v0.2.0` with lots of nice improvements and new features, I will post another blog on that soon.

To conclude this story, the Playground is becoming an integral part of the Kyverno ecosystem and we discovered ways to use it we didn't anticipate. For example, helping users troubleshoot their policies has never been easier. The share feature allows users to post links to the Playground for their particular policies and resources, this is a game changer for collaboration.


Last words, i can't thank Frank enough to have ignited the spark and his awesome work. Kudos Chip for all the suggestions, help and support. I can't wait to see how this small project turns out in the next releases :heart:
