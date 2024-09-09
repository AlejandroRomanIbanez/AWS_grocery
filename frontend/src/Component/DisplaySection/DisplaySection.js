import React from 'react';
import img1 from "../Assets/dp-img1.png";
import img2 from "../Assets/dp-img2.jpg";
import img3 from "../Assets/dp-img3.jpg";
import img4 from "../Assets/Healthy Food.png";
import img5 from "../Assets/Home Made.png";
import img6 from "../Assets/Natural.png";
import img7 from "../Assets/Fast Delivery.png";
import img8 from "../Assets/flowerkolly.png";
import cherry from "../Assets/cherry.png";
import tomato from "../Assets/tomato-slice.png";
import orange from "../Assets/orange-slice.png";
import plate from "../Assets/plate.png";
import { MdDoubleArrow } from 'react-icons/md';
import { TypeAnimation } from 'react-type-animation';
import "./DisplaySection.css";

const DisplaySection = () => {

    return (
        <div className='container mx-auto mt-6'>

            <div className='flex flex-wrap gap-6'>

                <div className='display-first-section relative flex-1'>

                    <img src={img8} className="absolute -z-10 w-full h-full object-cover" alt="" />

                    <div data-aos="fade-down" data-aos-duration="2000" className="absolute right-10 top-5">
                        <img src={cherry} alt="" />
                    </div>

                    <div data-aos="fade-right" data-aos-duration="2000" className="absolute right-[242px] bottom-[60px]">
                        <img src={tomato} alt="" />
                    </div>

                    <div data-aos="fade-left" data-aos-duration="2000" className="absolute right-10 bottom-7">
                        <img src={orange} alt="" />
                    </div>

                    <div className="absolute left-[-150px] bottom-[-180px]">
                        <img src={plate} className="rotate" alt="" />
                    </div>

                    <div className='content-sec-one'>
                        <h2>DELICIOUS</h2>
                        <h1>SALAD</h1>
                        <h3>
                            <TypeAnimation
                                sequence={['EVERYDAY.', 2000, '']}
                                speed={50}
                                repeat={Infinity}
                            />
                        </h3>

                        <div className='shop-now-btn ml-16 md:ml-20 lg:ml-40'>
                            <button>Shop Now</button>
                            <MdDoubleArrow className='ml-1 ' />
                        </div>
                    </div>
                    
                    <img src={img1} className="w-full" alt="" />
                </div>

                <div className='grid gap-6 flex-1'>

                    <div className='relative'>

                        <div className='content-section-two'>
                            <h1>Fresh</h1>
                            <h2>Vegetables</h2>

                            <div className='shop-now-btn'>
                                <button>Shop Now</button>
                                <MdDoubleArrow className='ml-1 ' />
                            </div>
                        </div>

                        <div className="hover05 column">
                            <div>
                                <figure>
                                    <img src={img2} alt="" className="w-full h-full object-cover" />
                                </figure>
                            </div>
                        </div>

                    </div>

                    <div className='relative'>

                        <div className='content-section-three'>
                            <h1>Fresh</h1>
                            <h2>Week Frenzy</h2>
                            <div className='shop-now-btn'>
                                <button>Shop Now</button>
                                <MdDoubleArrow className='ml-1 ' />
                            </div>
                        </div>

                        <div className="hover05 column">
                            <div>
                                <figure>
                                    <img src={img3} alt="" className="w-full h-full object-cover" />
                                </figure>
                            </div>
                        </div>
                    </div>

                </div>
            </div>

            {/* Sub Section */}
            <div className='sub-section mt-10 flex flex-wrap justify-center gap-10'>

                <div className='sub-section-cont flex items-center gap-4'>
                    <div className='main-section flex items-center gap-4'>
                        <img src={img4} className="w-24 h-24" alt="" />
                        <div>
                            <h2>Healthy Food</h2>
                            <p>It is a long established <br /> fact that </p>
                        </div>
                    </div>
                </div>

                <div className='sub-section-cont flex items-center gap-4'>
                    <div className='main-section flex items-center gap-4'>
                        <img src={img5} className="w-24 h-24" alt="" />
                        <div>
                            <h2>Home Made</h2>
                            <p>It is a long established <br /> fact that </p>
                        </div>
                    </div>
                </div>

                <div className='sub-section-cont flex items-center gap-4'>
                    <div className='main-section flex items-center gap-4'>
                        <img src={img6} className="w-20 h-20" alt="" />
                        <div>
                            <h2>100% Natural</h2>
                            <p>It is a long established <br /> fact that </p>
                        </div>
                    </div>
                </div>

                <div className='sub-section-cont flex items-center gap-4'>
                    <div className='main-section flex items-center gap-4'>
                        <img src={img7} className="w-30 h-16" alt="" />
                        <div>
                            <h2>Fast Delivery</h2>
                            <p>It is a long established <br /> fact that </p>
                        </div>
                    </div>
                </div>
            </div>

            <hr className='mt-8' />

        </div>
    );
};

export default DisplaySection;
