Select *
From PortfolioProject..CovidDeaths
where continent is not null
Order by 3, 4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3, 4

--Select Data that we are going to be using

Select Location, date, total_cases , new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
Order by 1,2


--Looking at Total cases Vs Total deaths
--Showss the likelihood of dying if you contract covid in your country

Select Location, date, total_cases , total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%Nigeria%'
Order by 1,2


--Looking at Total Cases Vs Population
--Shows what Percentage of Population has got Covid

Select Location, date, population, total_cases , (total_cases/population)*100 as PercentagePopolationInfected
From PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
Order by 1,2

--Looking at countries with highest infection rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentagePopolationInfected
From PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
Group by Location, Population
Order by PercentagePopolationInfected desc

--Showing Countries with highest Death Count per population

Select Location, population, MAX(Cast(total_deaths as int)) as HighestDeathCount 
From PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
Group by Location, Population
Order by HighestDeathCount desc


--LETS BREAK THINGS DOWN BY CONTINENT

--Showing Continent with Highest Death Count Per Polution

Select continent, MAX(Cast(total_deaths as int)) as HighestDeathCount 
From PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
Group by continent 
Order by HighestDeathCount desc


--GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_Deaths, SUM(Cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location is '%Nigeria%'
where continent is not null
--Group by date
Order by 1,2


--Looking at the Total Population Vs Vaccination

Select dea.continent, dea.location, dea. date, dea.Population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) Over (Partition by dea. Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
 On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
Order by 2,3


--USE CTE
With PopVSVacc (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea. date, dea.Population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) Over (Partition by dea. Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
--, (RollingPeolpleVaccinated/Population)*100
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
 On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentagePopulationVaccinated
From PopVSVacc



--TEMP TABLE
DROP Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea. date, dea.Population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) Over (Partition by dea. Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
--, (RollingPeolpleVaccinated/Population)*100
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
 On dea.location = vac.location
    and dea.date = vac.date
--where dea.continent is not null
--Order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100 as PercentagePopulationVaccinated
From #PercentagePopulationVaccinated


--Create view to store data for later Visualizations

Create view PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea. date, dea.Population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) Over (Partition by dea. Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
--, (RollingPeolpleVaccinated/Population)*100
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
 On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--Order by 2,3



Select * 
From PercentagePopulationVaccinated
