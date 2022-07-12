Select *
From PortfolioProject..CovidDeaths$
Order by 3,4


-- Select Data that we are going to be using


Select Location, date, total_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Order by 1,2



-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where location like '%states%'
Order by 1,2


-- Looking at Total Cases Vs Population
-- Shows What Percentage of Population got Covid

Select Location, date, population, total_cases,  (total_cases/population) *100 as InfectedPercentage
From PortfolioProject..CovidDeaths$
--where location like '%states%'
Order by 1,2



-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, Max(total_cases) as HighestInfectionCount,  Max((total_cases/population)) *100 as InfectedPercentage
From PortfolioProject..CovidDeaths$
--where location like '%states%'
Group by Location, Population
Order by InfectedPercentage desc


-- Showing Countries with Highest Death Count Per Population

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--where location like '%states%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc

-- Lets Break things down by Continent


-- Showing Continents with the Highest Death Count per Population

Select Continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Global Numbers

Select date, Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%states%'
Where continent is not null
group by date
order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 1,2

) Select *, (RollingPeopleVaccinated/Population) * 100
from PopvsVac



-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 1,2

 Select *, (RollingPeopleVaccinated/Population) * 100
from #PercentPopulationVaccinated



-- Creating View to store data for visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 1,2