# COVID-in-Prisons
<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]




<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary><h2 style="display: inline-block">Table of Contents</h2></summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
      </ul>
    </li>
    <li><a href="#future-work">Future Work</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project
\
[COVID-in-Prisons Website](https://covid-in-prisons.carrd.co/)
\
\
We analyzed the effect of COVID-19 in the Correctional Facility system of the United States. While analyzing data provided by the UCLA COVID-19 Behind Bars Project we created several interactive Shiny apps in R to allow other users to explore the visualizations. 


### Built With

* [R programming](https://www.r-project.org/about.html)
* [Shiny R](https://shiny.rstudio.com/)
* [Carrd.co](https://carrd.co/)



<!-- GETTING STARTED -->
## Getting Started

To explore the visualizations navigate to: [https://covid-in-prisons.shinyapps.io/COVID-in-Prisons/](https://covid-in-prisons.shinyapps.io/COVID-in-Prisons/)

### Prerequisites

If you are interested in cloning the repository and exploring the data further you will need to make sure you install several packages.
* install.packages("shiny")
* install.packages("shinydashboard")
* install.packages("maps")
* install.packages("dplyr")
* install.packages("stringr")
* install.packages("ggplot2")

The main shiny dashboard application is under "final-dashboard" title "app.r". This file can be opened in Rstudio and run from the client as is. 
\
Maps is not needed for running, but it was used to get the initial data. Dplyr and stringr are used for data manipulation. Shiny, shinydashboard, and ggplot2 are used for visualizations.
\
The Exploration.Rmd is a markdown file where we did our initial exploration of the data.

<!-- FUTURE -->
## Future Work

* Gather comprehensive data on all facility populations to use population based rates.
* Perform regression analysis to see if state prison cases are different from general population cases.
* Gather data over time for releases in facilities to see effectiveness of releasing inmates and preventing the spread of COVID-19.
* Gather data for public vs. private prisons to see if our trends follow throughout the U.S.


<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.



<!-- CONTACT -->
## Contact

Jakob Orel - jorel22@cornellcollege.edu
\
Danielle Amonica - damonica21@cornellcollege.edu
\
Kenna Ebert - kebert22@cornellcollege.edu
\
Jonathan Shilyansky - jshilyansky23@cornellcollege.edu

Project Link: [https://github.com/jakoborel/COVID-in-Prisons](https://github.com/jakoborel/COVID-in-Prisons)





<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/jakoborel/COVID-in-Prisons.svg?style=for-the-badge
[contributors-url]: https://github.com/jakoborel/COVID-in-Prisons/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/jakoborel/COVID-in-Prisons.svg?style=for-the-badge
[forks-url]: https://github.com/jakoborel/COVID-in-Prisons/network/members
[stars-shield]: https://img.shields.io/github/stars/jakoborel/COVID-in-Prisons.svg?style=for-the-badge
[stars-url]: https://github.com/jakoborel/COVID-in-Prisons/stargazers
[issues-shield]: https://img.shields.io/github/issues/jakoborel/COVID-in-Prisons.svg?style=for-the-badge
[issues-url]: https://github.com/jakoborel/COVID-in-Prisons/issues
[license-shield]: https://img.shields.io/github/license/jakoborel/COVID-in-Prisons.svg?style=for-the-badge
[license-url]: https://github.com/jakoborel/COVID-in-Prisons/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/jakob-orel
