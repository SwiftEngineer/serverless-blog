# Serverless Blog

Get ready for some buzzwords, because things are about to get crazy. This project uses a series of Dockerized services to create a completely serverless application up in the cloud. I wanted to create a project that showcased some techs that I've worked with over the past, as well as get some experience in stuff I've never used before.

This project is **purely for education**. However, if you want to fork it and use the stack to create your own project that's fine too.

**IMPORTANT DISCLAIMERS:** 

1. Using a stack like this to implement a simple Blog is complete overkill, and if you wanted to create your own Blog I would recommend you use a service designed for blogging instead of this. This project is to be used solely for those of you who are looking for new ways to think about Full-Stack development, or people who just plain want to learn more about programming in general. There is a ton here, and hopefully I'll be able to continue to make posts explaining it long into the future.
1. I'm using docker-compose here just to allow people to deploy the app from start to finish with a single command, and give people a thousand foot view of what's going on. The code in this repo is NOT an example of end-to-end content development to delivery or CI/CD. That is way out of scope. This repo mainly just shows how you can use terraform in a serverless environment to make your life easier.

## What the heck is going on in the Code above?

Before we get into the **how**, I thought I'd give shoutouts to the following tech to get everything working and highly recommend you check them out. Although I don't recommend using them the way I used them here, they could do wonders for your project's dev/test environment:
1. **Docker** - If you're not familiar with it, don't fret. All it is is an easy way for us to keep each of our services running in seperate virtual machines called "containers".
1. **Docker Compose** - A tool for dev/test environments that allows simple orchistration of Dockerized services (a.k.a containers).
1. **AWS SAM Local** - Pretty cool service that allows you to emulate Api Gateway via Docker. Great for testing or developing against the AWS Lambda service.

### How is it used?

The code in this repos can be viewed at a high level from the [docker-compose.yml](docker-compose.yml) file. This file shows a breakdown of all the services that come together to form the Blog.

It describes 5 services but for our terraform deployment we only really care about 3 of them. These critical services are the `tf` (deployment) service, `ui` (client build process) service, `api` (api build process) service. There are two "phases" of the deployment process where each container is given a specific job.

#### Phase 1

The first phase begins by running `docker-compose up`, which creates a container for each of our services. These containers each do different things all at the same time. 

**TL;DR The goal of this phase is ready our Terraform container, and build production ready versions of our API and UI.**

![phase1](https://i.imgur.com/K2KeafB.png)

- **Terraform Service** -> tf \
    The Terraform service is a bit special. Instead of copying data *into* the volume we mount to it, instead it copies data *from* this volume **(Fig I.)**. The `/blog-infrastructure-terraform` volume is basically a symlink to the `.tf` code in this very repo. In a typical CI/CD pipeline, you'd probably want to just build this image with the `.tf` code already in it. In this first phase, the production ready code for the UI and API probably isn't built yet, so I just set the Terraform Service to poll each of the ui and api services and not do anything until they show they are done by hosting a development version of their own app **(Fig II.)**. Pretty hacky, but we aren't trying to make a production ready app here, we're just showing how terraform works.

- **API Service** -> api \
    The api service's goal during this phase is to build the assets as fast as possible. Before it does this however, we mount the `/lambda_ready_app` volume to it. The code will be built in this volume **(Fig III.)**, which is basically just a symlink to our local machine's filesystem. This allows us (and more importantly the "tf" service) to access the production ready code without SSHing into the container or streaming it. After it has made the fresh production ready version of the code available to the docker host via the volume mount, it will start up a local instance of the service via AWS SAM Local.

- **UI Service** -> ui \
    The ui service does pretty much the exact same thing as the API service during this phase. After the `/s3_ready_app` volume is mounted, it will begin to build the code and copy it into the volume ASAP **(Fig III.)**. Once it's ready, it will start up a local instance of the service.


#### Phase 2

The second phase begins after the user runs a few commands. At this point the `api` and `ui` services will be networked together to run a local version of the app, but we don't care about that. What we care about is the `tf` service, more specifically how we are going to get it to deploy our code. You may remember that we copied the production ready versions of the API and UI to the `/lambda_ready_app` and `/s3_ready_app` volumes respectively. Well, in this phase we will feed that code to the `tf` service so that it can provision infrastructure for it and get our app started.

**TL;DR Now that we have our production ready code, the goal of this phase is to deploy it.**

![phase2](https://i.imgur.com/47Wy07p.png)

- **Terraform Service** -> tf \
    Terraform stays super busy during this phase. Now that the production ready code is available via the
    `/lambda_ready_app` and `/s3_ready_app` volumes, we can attach to it via `docker attach serverless-blog_tf_1`. This is basically like `ssh`ing into the service. Once we are in, we can run `terraform apply -var-file="secrets.tfvars"`. This tell terraform to create a plan to upload each of these codebases into their own S3 buckets. Once it's finished planning, it will present the plan to us and if we accept it, it will being to send a TON of rest requests out to AWS to provision and configure the infrastructure we requested. This includes setting up things like our API Gateway, Cloudfront Distribution, DynamoDB, as well as our Lambda Functions.

- **API Service** -> api \
    This service will just be sitting there hosting the local version of the app. We are pretty much ignoring it now that it's already informed the Terraform service that the API code was delivered.

- **UI Service** -> ui \
    Same as the API. It will host the local version of the app, and relax.

## Why use Docker to Build and Deploy each service?

We use a docker container to build and deploy each service. Why? Docker let's us manage the environment in which our code is built and deployed, which gives us a lot of power. Versioning the code is one thing, but being able to version the environment our code is built in is gonna make a few things easier:

- Dependencies are managed by the Docker container, instead of a developer's machine which may have slightly different versions of things, or even just a bad install of Node.js. Unlikely, but would make for one heck of a long weekend debugging prod. NPM packages have been known in the past to sometimes disappear from npm altogether, which can cause a TON of pain. What about assets like images or dependencies that we brought in that aren't in the `package-lock.json` file? Compiled ES2017 Babel scripts? ENV variables? There's a lot to think about, but if we use Docker, we only have to worry about this stuff at the time of building the original image, as that is when the dependencies are baked into it. \
**TL;DR:** Insure that the dependencies for each of the services remain unchanged and available.

- Any machine with Docker can both build and deploy the project, it just needs the creds. So whether you want to deploy the code from your CI/CD service, that Dell machine in the basement or even Tom's crappy laptop, it's gonna be safe and easy. \
**TL;DR:** Allow anyone with creds the ability to build, test, and deploy the project.

- You're a good developer, right? So you probably don't write tests that would modify any files on the filesystem that deploys your code. I too think that sounds scary and wouldn't do it... but do you think those new interns that just got brought onto your team would get that? Good news is that even if they mess it up, you can just throw that container away and bring up a new one. \
**TL;DR:** Provides insulation from some of the costly mistakes people can make during the Continuous Deployment pipeline.

- Most importantly, it keeps our options open for the future. Due to the fact that each of these services are dockerized, they can easily be plugged into a CI/CD service or used by an automation script, as long as that service has support for Docker (which all of the ones I've had sucess in the past with do).
**TL;DR:** Provides insulation from some of the costly mistakes people can make during the Continuous Deployment pipeline.

So to summarize, why do we use Docker to build and deploy the UI? We use it so we can manage dependencies, keep our services portable and save ourselves from some potentially time consuming mistakes. People talk a lot about using Docker to deploy applications, but I think sometimes people miss out on the fact that Docker can solve a lot of issues within your Dev/Test/Build cycle as well.

## WARNING TO THOSE WHO FORK THIS:

1. Please. Please. Please. Do not use docker-compose to deploy your stuff. Use a CI/CD Pipeline. I've said this before and I'll say it again, I'm using docker-compose here just to allow people to deploy the app from start to finish with a single command.
1. Do the terraform apply
1. If you bought the cert from someone else besides amazon, you're gonna have to switch up the name servers on that domain. To get the state of our Route53 Zone you should run something like the following:

```
swift@Taylors-MacBook-Pro $ terraform state show aws_route53_zone.zone

id             = ##############
comment        = Managed by Terraform
force_destroy  = false
name           = doing.science
name_servers.# = 4
name_servers.0 = ns-###.awsdns-###.org
name_servers.1 = ns-###.awsdns-###.co.uk
name_servers.2 = ns-###.awsdns-###.com
name_servers.3 = ns-###.awsdns-###.net
tags.%         = 0
zone_id        = ##############
```