import { Zap } from "lucide-react";
import { heroTags } from "../constants";
import { Tag } from "../components/Tag";
import { Button } from "../components/Button";
import { motion } from "motion/react";



export const HeroSection = () => {
  
  const zapIcon = Zap;
  
    return (
        <section
         className="w-full bg-linear-to-br from-dark-50 to-dark-100 relative py-10 sm:p-20">
            
            <img src="assets/images/lg-hero-ball.svg" alt="lg-hero-ball" className="
            hidden sm:inline-block absolute sm:top-20 sm:left-8 lg:top-20 
            lg:left-20"/>
            <img src="assets/images/sm-hero-ball.svg" alt="sm-hero-ball" className="hidden
            sm:inline-block absolute sm:right-15 sm:top-50 md:right-25
            lg:top-50 lg:right-50 xl:right-90 "/>

            <div 
              className="container py-10 sm:py-0 sm:px-10 flex flex-col justify-center 
            items-center text-center space-y-6">
                <Tag variant='primary' Icon={zapIcon}>
                  Introducing CEL Policies
                </Tag>
                <h1 className="w-full text-5xl px-2 sm:text-[52px] md:text-6xl font-bold tracking-wide text-primary-100 
                capitalize leading-12 sm:leading-16 ">
                    Unified
                  <span className="text-white block">Policy as code</span>
                  <span className="text-accent-100 block">For platform engineers</span>
                </h1>
                <p className="text-[1rem] sm:text-lg max-w-80 sm:max-w-150 leading-6">
                  Kyverno, created by Nirmata, makes it simple to secure, 
                  automate, and manage your infrastructures and applications 
                  using Kubernetes-native YAML and CEL. Easy-to-learn and 
                  powered by the CNCF community.
                </p>
                <div className="flex flex-col justify-center items-center lg:flex-row space-y-3 lg:justify-between 
                lg:items-baseline lg:space-x-3">
                {heroTags.map((tag) => (
                    <Tag Icon={tag.icon} variant='tertiary' key={tag.title}>{tag.title}</Tag>
                ))}
             </div>
            <div className="flex flex-col space-y-4 sm:flex-row sm:space-x-4 sm:space-y-0">
              <Button href='/docs/quickstart' variant='primary' size='large'>
                   Quickstart   
              </Button>
              <Button href='/docs/introduction' variant='secondary' size='large'>
                   Read Documentation  
              </Button>
          </div>
        </div>
        </section>
    )
}