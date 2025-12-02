import { Zap } from "lucide-react";
import { heroTags } from "../constants";




export const HeroSection = () => {

    return (
        <section className="w-full bg-linear-to-br from-dark-50 to-dark-100 
        relative py-10 sm:p-20">

            <img src="assets/images/lg-hero-ball.svg" alt="lg-hero-ball" className="
            hidden sm:inline-block absolute sm:top-20 sm:left-8 lg:top-20 
            lg:left-20"/>
            <img src="assets/images/sm-hero-ball.svg" alt="sm-hero-ball" className="hidden
            sm:inline-block absolute sm:right-15 sm:top-50 md:right-25
            lg:top-50 lg:right-50 xl:right-90 "/>

            <div className="container py-10 sm:py-0 sm:px-10 flex flex-col justify-center 
            items-center text-center space-y-6">
                <div className="w-60 h-8 sm:h-10 sm:w-70 flex justify-center items-center space-x-2 
                rounded-4xl bg-primary-100 text-[12px] sm:text-sm">
                  <Zap className="w-5 h-5"/>
                  <span>Introducing CEL-Based Policies</span>
                </div>
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
                <div className="flex flex-col sm:flex-row space-y-3 sm:justify-between 
                sm:items-baseline sm:space-x-2 md:space-x-3">
                {heroTags.map((tag) => (
                    <div key={tag.title} className="h-10 flex justify-center 
                    items-center space-x-2 rounded-full p-4 border 
                    border-stroke text-white/70 sm-w-1/3" >
                        <tag.icon className="w-4 h-4"/>
                        <p className="text-nowrap text-sm sm:text-[12px] lg:text-sm">{tag.title}</p>
                    </div>
                ))}
             </div>
            <div className="flex flex-col space-y-4 sm:flex-row sm:space-x-4">
                <a href="#" className='w-50 h-10 bg-primary-100 flex justify-center items-center 
                rounded-md hover:bg-white hover:text-primary-100 '>
                      Get Started
                </a>
                <a href="#" className='w-50 h-10 justify-center items-center py-2 
                px-3 border border-primary-100 rounded-md hover:border hover:border-white  bg-'>
                        Read Documentation
                </a>
              </div>
            </div>
        </section>
    )
}