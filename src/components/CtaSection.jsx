
export const CtaSection = () => {
  return (
    <section className="w-full p-16 flex flex-col space-y-6 bg-dark-50 items-center">
        <h2 className="font-bold text-xl">Get started with Kyverno</h2>
        <p>Deploy Kyverno in your Kubernetes cluster within minutes and start writing policies using simple, familiar YAML.</p>
         <div className="flex flex-col space-y-4 sm:flex-row sm:space-x-4">
                <a href="#" className='w-50 h-10 bg-primary-100 flex justify-center items-center 
                rounded-md hover:bg-white hover:text-primary-100 '>
                      Get Started
                </a>
                <a href="#" className='w-50 h-10 flex justify-center items-center py-2 
                px-3 border border-primary-100 rounded-md hover:border hover:border-white'>
                        Explore Policies
                </a>
         </div>
    </section>
  )
}

