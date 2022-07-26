SELECT *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3, 4

SELECT *
From PortfolioProject..CovidVaccinations
Order by 3, 4

--DATA OBSERVATION
Select Location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1, 2

--TOTAL CASES VS TOTAL DEATHS - ALTOGETHER(SUM)

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
Where Continent is not null
Order by 1,2

--TOTAL DEATH COUNT GROUPED BY LOCATION (CONTINENT)
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
and location not in ('World', 'European Union', 'International')
Group by location
Order by TotalDeathCount desc

--PERCENTAGE OF POPULATION INFECTED GROUPED BY LOCATION
Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
Order by PercentPopulationInfected desc

--PERCENTAGE OF POPULATION INFECTED GROUPED BY LOCATION & DATE

Select Location, Population, date, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date
Order by PercentPopulationInfected desc


--QUERIES TO EXPAND ON WITHIN TABLEAU

--Total Cases vs Total Deaths 
--Shows the likelihood of dying if you contract covid in your country 
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
--Where location like '%canada%'
Order by 1, 2

--Looking at the Total Cases vs Population
--Shows what percentage of population got Covid
Select Location, date, total_cases, Population, (total_cases/population)*100 as ContractedPercentage 
From PortfolioProject..CovidDeaths
--Where location like '%canada%'
Where continent is not null
Order by 1, 2

--Looking at countries with highest infection rate compared to population

Select Location,Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as ContractedPercentage 
From PortfolioProject..CovidDeaths
--Where location like '%canada%'
Group by Location, Population
Order by ContractedPercentage  desc

--Showing Countries with High Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%canada%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc

--Breaking Table down by Continent 

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%canada%'
Where continent is null
Group by location
Order by TotalDeathCount desc

--Showing Continents with the highest Death Count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%canada%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc

--Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1, 2

--Global Numbers total all together

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
Order by 1, 2

--Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea	
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3

--WITH CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea	
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)

Select * , (RollingPeopleVaccinated/Population) * 100
From PopvsVac

--Creating View to store data for later visualizations

--VIEW ROLLING VACCINATION

Create View RollingPeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea	
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null

Select *
From RollingPeopleVaccinated

--VIEW TOTAL CASES VS TOTAL DEATHS

Create View TotalCasesvsTotalDeaths as
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
--Where location like '%canada%'
Where continent is not null

Select *
From TotalCasesvsTotalDeaths

--VIEW TOTAL CASES VS TOTAL POPULATION - PERCENTAGE

CREATE VIEW ContractedPercentage as
Select Location, date, total_cases, Population, (total_cases/population)*100 as ContractedPercentage 
From PortfolioProject..CovidDeaths
--Where location like '%canada%'
Where continent is not null

Select *
From ContractedPercentage






