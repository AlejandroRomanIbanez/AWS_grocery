import React from 'react';
import Brands from '../Brands/Brands';
import DisplaySection from '../DisplaySection/DisplaySection';
import "./Home.css";

const Home = () => {

    return (
        <div>
            <DisplaySection />
            <Brands />
        </div>
    );
};

export default Home;