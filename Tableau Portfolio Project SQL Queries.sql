/*
Queries used for Tableau Project
*/



-- 1. 

Select SUM(dea.new_cases) as total_cases, SUM(cast(dea.new_deaths as int)) as total_deaths
, SUM(cast(vac.new_vaccinations as int)) as total_vaccinations
, SUM(cast(dea.new_deaths as int))/SUM(dea.New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
--Where location = 'Australia'
where dea.continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location = 'Australia'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location = 'Australia'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location = 'Australia'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location = 'Australia'
Group by Location, Population, date
order by PercentPopulationInfected desc


-- 5.


Select location, SUM(cast(new_cases as int)) as TotalCaseCount
From PortfolioProject..CovidDeaths
--Where location = 'Australia'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalCaseCount desc


-- 6.


Select location, SUM(cast(new_vaccinations as int)) as TotalVaccinationCount
From PortfolioProject..CovidVaccinations
--Where location = 'Australia'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalVaccinationCount desc


-- 7.


Select Location, MAX(cast(people_vaccinated_per_hundred as float)) as HighestVaccinationCount
From PortfolioProject..CovidVaccinations
--Where location not in ('World', 'European Union', 'International','Oceania', 'Africa', 'Asia')
Group by Location
order by HighestVaccinationCount desc
