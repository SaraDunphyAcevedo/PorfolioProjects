SELECT*
FROM PortfolioProject.DBO.CovidDeaths
where continent is not null
ORDER BY 3,4

--SELECT*
--FROM PortfolioProject.DBO.CovidVaccinations
--ORDER BY 3,4

--Select data that we are going to be using
SELECT 
[location]
,[date]
,total_cases
,new_cases
,total_deaths
,[population]
FROM PortfolioProject.DBO.CovidDeaths
where continent is not null
ORDER BY 1,2

-- Looking at total cases vs total deaths--left off at 22:45 on video
--Shows the likelihood of dying if you contract covid in your country

SELECT 
[location]
,[date]
,total_cases
,total_deaths
,(total_deaths/total_cases)*100 as DeathPercentageOfCases

FROM PortfolioProject.DBO.CovidDeaths
where location like '%states%'
ORDER BY 1,2

--Looking at the total cases vs population

SELECT 
[location]
,[date]
,population
,total_cases

,(total_cases/population)*100 as PercentageOfPopulation

FROM PortfolioProject.DBO.CovidDeaths
where location like '%states%'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population
SELECT 
[location]
,population
,max(total_cases) as HighestInfectionCount

,max((total_cases/population))*100 as PercentPopulationInfected

FROM PortfolioProject.DBO.CovidDeaths
--where location like '%states%'
GROUP BY location,population
order by PercentPopulationInfected desc


--LET'S BREAK THINGS DOWN BY CONTINTENT
SELECT 
continent
,max(CAST(total_deaths as int)) as TotalDeathCount

FROM PortfolioProject.DBO.CovidDeaths
--where location like '%states%'
where continent is not null
GROUP BY continent
order by TotalDeathCount desc

--Showing the continents with the highest death count per population
SELECT 
continent
,max(CAST(total_deaths as int)) as TotalDeathCount

FROM PortfolioProject.DBO.CovidDeaths
--where location like '%states%'
where continent is not null
GROUP BY continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
SELECT 
[date]
,SUM(new_cases)
,SUM(CAST(NEW_DEATHS AS INT))
,SUM(CAST(NEW_DEATHS AS INT))/SUM(new_cases)*100 AS DeathPercentages
--,total_deaths
--,(total_deaths/total_cases)*100 as DeathPercentageOfCases

FROM PortfolioProject.DBO.CovidDeaths
--where location like '%states%'
WHERE CONTINENT IS NOT NULL
GROUP BY DATE
ORDER BY 1,2


--Looking at Total Population vs Vaccinations

--USE CTE 
with PopvsVac (Continent, location,date,population,new_vaccinations,RollingPeopleVaccinated)
as 
(select
dea.continent
,dea.location
,dea.date
,dea.population
,vac.new_vaccinations
,SUM(Convert(int,vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolioproject..covidvaccinations DEA
JOIN portfolioproject..covidvaccinations VAC
	ON  DEA.LOCATION=VAC.LOCATION
	 AND DEA.DATE=VAC.DATE
WHERE DEA.CONTINENT IS NOT NULL)
select*, (RollingPeopleVaccinated/population)*100
from PopvsVac



--TEMP TABLE
ALTER TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeoplevaccinated numeric)
INSERT INTO #PercentPopulationVaccinated
select
dea.continent
,dea.location
,dea.date
,dea.population
,vac.new_vaccinations
,SUM(Convert(int,vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from portfolioproject..covidvaccinations DEA
JOIN portfolioproject..covidvaccinations VAC
	ON  DEA.LOCATION=VAC.LOCATION
	 AND DEA.DATE=VAC.DATE
WHERE DEA.CONTINENT IS NOT NULL

select*, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as 
select
dea.continent
,dea.location
,dea.date
,dea.population
,vac.new_vaccinations
,SUM(Convert(int,vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from portfolioproject..covidvaccinations DEA
JOIN portfolioproject..covidvaccinations VAC
	ON  DEA.LOCATION=VAC.LOCATION
	 AND DEA.DATE=VAC.DATE
WHERE DEA.CONTINENT IS NOT NULL

Select
*
from PercentPopulationVaccinated