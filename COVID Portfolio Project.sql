/*
Covid-19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

-- Select the Data that we are going to be starting with

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract Covid-19 in Australia

select location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 2) as DeathPercentage
from PortfolioProject..CovidDeaths
where location = 'Australia'
order by 1,2

-- Total Cases vs Population
-- Shows the percentage of the population that has contracted Covid-19 in Australia

select location, date, population, total_cases, ROUND((total_cases/population)*100, 2) as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location = 'Australia'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

select location, population, MAX(total_cases) as HighestInfectionCount, ROUND(MAX((total_cases/population))*100, 2) as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc

-- Countries with the Highest Death Count

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- Highest Death Count by Continent

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null 
group by continent
order by TotalDeathCount desc

-- Global number of Total cases, total deaths and the likelihood of death if Covid-19 is contracted 

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths
, ROUND(SUM(CAST(new_deaths as int))/SUM(new_cases)*100, 2) as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Total Population vs Vaccinations
-- Shows percentage of population that has received at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.date) as CumulativeVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE to perform calculation on partition by in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, CumulativeVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.date) as CumulativeVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, ROUND((CumulativeVaccinations/Population)*100, 2) as VaccinatedPercentage
from PopvsVac

-- Using a TEMP TABLE to perform calculation on partition by in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CumulativeVaccinations numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.date) as CumulativeVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (CumulativeVaccinations/Population)*100 as VaccinatedPercentage
from #PercentPopulationVaccinated

-- Creating View to store data for later visualisations 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.date) as CumulativeVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null

