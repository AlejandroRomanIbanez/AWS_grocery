import React from 'react';
import "./Brands.css";
import img2 from "../Assets/brand2.png";
import img3 from "../Assets/brand3.png";
import img4 from "../Assets/brnad4.png";
import img5 from "../Assets/brand5.png";
import img6 from "../Assets/brnad6.png";

const Brands = () => {
    return (
        <div className='brands-container mx-auto mt-15'>

            <div data-aos="fade-up" data-aos-duration="1500" className='brands-content flex flex-wrap justify-center items-center gap-10'>
                <img src={img2} className="brandImg" alt="Brand 2" />
                <img src={img3} className="brandImg" alt="Brand 3" />
                <img src={img4} className="brandImg" alt="Brand 4" />
                <img src={img5} className="brandImg" alt="Brand 5" />
                <img src={img6} className="brandImg" alt="Brand 6" />
            </div>

        </div>
    );
};

export default Brands;
