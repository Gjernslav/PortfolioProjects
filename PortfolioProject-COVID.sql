Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

--Select Datathat we are going to be using

--Select Location, date,total_cases, new_cases, total_deaths, population
--From PortfolioProject..CovidDeaths
--Order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contracted Covid in your country
Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2


--Look at Total Cases VS Population
--Shows what percentage of population contracted Covid

Select Location, date,population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Order by 1,2

--Looking at countries with highest infection rate compared to populations

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, population
Order by  PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population


Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc

--	LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing the Continents with the highest death counts

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) /SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE continent is not null
--Group by date
Order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) *100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
WHERE dea.continent is not null
Order by 2,3



--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) *100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) *100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) *100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3
