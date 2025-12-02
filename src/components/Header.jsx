import React, { useState } from 'react';
import { navItems, navItemsExternal, navItemsOnsite } from '../constants/index.js';
import {Menu, X} from 'lucide-react';


export const Header = () => {

    const [mobileNavOpen, setMobileNavOpen] = useState(false);
    const toggleMobileNav = () => {
        setMobileNavOpen(!mobileNavOpen);
    }

    const handleScroll = (event, targetId) => {
        event.preventDefault();
        const targetElement = document.getElementById(targetId);
        if(targetElement) {
            const offsetTop = targetElement.offsetTop - 80;
            window.scrollTo({
                top: offsetTop,
                behavior: 'smooth'
            })
        }
        setMobileNavOpen(false);
    }

  return (
    <nav className='sticky top-0 z-50 py-3 backdrop-blur-lg border-b 
    border-neutral-700/80'>
        <div className='container px-4 md:w-full md:px-0 lg:px-4 mx-auto relative text-sm'>
            <div className='flex justify-between items-center'>
                <div className="flex space-x-3 hover:text-accent-100 cursor-pointer">
                    <img src='kyverno-logo.svg' alt="kyverno logo" className='
                    w-8 h-8'/>
                    <span className='text-xl tracking-tight font-bold'>Kyverno</span>
                </div>
                <div className='hidden lg:flex justify-between items-center md:text-sm xl:text-lg space-x-12'>
                    <ul className='flex lg:flex justify-between items-center space-x-12'>
                        {navItemsOnsite.map((item, index) => (
                                <li key={index} className='hover:text-accent-100 
                            active:text-accent-50'>
                                    <a href={`#${item.targetId}`} onClick={(e) => handleScroll(e, item.targetId)}>
                                    {item.label}
                                    </a>
                                </li>
                            ))}
                        </ul>
                        <ul className='flex lg:flex justify-between items-center space-x-12'>
                            {navItemsExternal.map((item, index) => (
                                <li key={index} className='hover:text-accent-100 
                            active:text-accent-50'>
                                    <a href={item.href}>
                                    {item.label}
                                    </a>
                                </li>
                            ))}
                     </ul>
                </div>
                <div className="hidden lg:flex md:text-sm xl:text-lg justify-center space-x-6 
                items-center">
                    <a href="https://playground.kyverno.io/" className='py-2 px-3 border border-primary-100 
                    rounded-md hover:border hover:border-white'>
                       Playground
                    </a>
                    <a href="https://kyverno.io/support/" className='bg-primary-100 py-2 px-3 rounded-md hover:bg-white hover:text-primary-100'>
                       Support
                    </a>
                </div>
                <div className="lg:hidden flex flex-col justify-end">
                    <button onClick={toggleMobileNav}>
                        {mobileNavOpen ? <X /> : <Menu />}
                    </button>
                </div>
            </div>
             {mobileNavOpen && (
                <div className="fixed right-0 z-20 bg-dark-50 w-full p-12 flex 
                flex-col justify-start items-center space-y-3 lg:hidden" >
                    <div>
                    <ul>
                        {navItemsOnsite.map((item, index) => (
                            <li key={index} className='py-4'>
                                <a href={`#${item.targetId}`} onClick={(e) => handleScroll(e, item.targetId)}>
                                {item.label}
                                </a>
                            </li>
                        ))}
                    </ul>
                    <ul>
                        {navItemsExternal.map((item, index) => (
                            <li key={index} className='py-4'>
                                <a href={item.href}>
                                {item.label}
                                </a>
                            </li>
                        ))}
                    </ul>
                    </div>
                    <div className="lg:hidden flex space-x-2">
                        <a href="https://playground.kyverno.io/" className='py-2 px-3 border border-primary-100 
                    rounded-md hover:border hover:border-white'>
                       Playground
                         </a>
                         <a href="https://kyverno.io/support/" className='bg-primary-100 py-2 px-3 rounded-md 
                         hover:bg-white hover:text-primary-100'>
                        Support
                         </a>
                    </div>
                    </div>
                    )}
                </div>
        </nav>

 )
}