import React, { useState } from 'react';
import { TopBanner } from '../components/TopBanner.jsx';
import { TopNav } from '../components/TopNav.jsx';


export const Header = () => {

    const [isBannerVisible, setIsBannerVisble] = useState(true);

    const handleCloseBanner = () => {
        setIsBannerVisble(false);
    };


  return (
    <header className='w-full sticky z-50 top-0'>
        {isBannerVisible && < TopBanner onClose={handleCloseBanner} client:load/>}
        <TopNav />
    </header>

 )
}