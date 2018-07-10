# Serverless Blog

Get ready for some buzzwords, because things are about to get crazy. This project uses a series of Dockerized services to create a completely serverless application up in the cloud. I wanted to create a project that showcased some techs that I've worked with over the past, as well as get some experience in stuff I've never used before.

This project is **purely for education**. However, if you want to fork it and use the stack to create your own project that's fine too.

**IMPORTANT DISCLAIMER:** Using a stack like this to implement a simple Blog is complete overkill, and if you wanted to create your own Blog I would recommend you use a service designed for blogging instead of this. This project is to be used solely for those of you who are looking for new ways to think about Full-Stack development, or people who just plain want to learn more about programming in general. There is a ton here, and hopefully I'll be able to continue to make posts explaining it long into the future.

## Why use Docker to Build and Deploy each service?

We use a docker container to build and deploy each service. Why? Docker let's us manage the environment in which our code is built and deployed, which gives us a lot of power. Versioning the code is one thing, but being able to version the environment our code is built in is gonna make a few things easier:

- Dependencies are managed by the Docker container, instead of a developer's machine which may have slightly different versions of things, or even just a bad install of Node.js. Unlikely, but would make for one heck of a long weekend debugging prod. What about assets like images or dependencies that we brought in that aren't in the `package-lock.json` file? Compiled ES2017 Babel scripts? ENV variables? There's a lot to think about, but if we use Docker it get's pretty easy. \
**TL;DR:** Version all the dependencies (including things like website assets).

- Any machine with Docker can both build and deploy the project, it just needs the creds. So whether you want to deploy the code from your CI/CD service, that Dell machine in the basement or even Tom's crappy laptop, it's gonna be safe and easy. \
**TL;DR:** Allow anyone with creds the ability to build, test, and deploy the project.

- You're a good developer, right? So you probably don't write tests that would modify any files on the filesystem that deploys your code. I too think that sounds scary and wouldn't do it... but do you think those new interns that just got brought onto your team would get that? Good news is that even if they mess it up, you can just throw that container away and bring up a new one. \
**TL;DR:** Provides insulation from some of the costly mistakes people can make during the Continuous Deployment pipeline.

So to summarize, why do we use Docker to build and deploy the UI? We use it so we can manage dependencies, keep our services portable and save ourselves from some potentially time consuming mistakes.