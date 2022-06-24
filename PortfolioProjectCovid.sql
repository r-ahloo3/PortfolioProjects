SELECT * 
From [Portfolio Project]..[Covid Deaths]
Where continent is not null
Order By 3,4

--SELECT * 
--From [Portfolio Project]..[Covid Vaccinations]
--Order By 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..[Covid Deaths]
Where continent is not null
Order By 1,2

--Looking at Total cases vs Total Deaths

Select Location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..[Covid Deaths]
Where Location like '%states%'
Order By 1,2

--Looking at Total Cases vs Population

Select Location, date, Population, total_cases, (total_cases/population)*100 as DeathPercentage
From [Portfolio Project]..[Covid Deaths]
Order by 1,2

-- Looking at countries with Highest Infection Rate compared to population

Select Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..[Covid Deaths]
Where continent is not null
Order By PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..[Covid Deaths]
Where continent is not null
Group By Location
Order By TotalDeathCount desc

-- Breakdown by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..[Covid Deaths]
Where continent is not null
Group By continent
Order By TotalDeathCount desc

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project]..[Covid Deaths]
where continent is not null
Order By 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingVaxCount
From [Portfolio Project]..[Covid Deaths] dea
Join [Portfolio Project]..[Covid Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaxCount)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingVaxCount
From [Portfolio Project]..[Covid Deaths] dea
Join [Portfolio Project]..[Covid Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingVaxCount/Population)* 100
From PopvsVac


-- Creating Views for Visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingVaxCount
From [Portfolio Project]..[Covid Deaths] dea
Join [Portfolio Project]..[Covid Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated

Create View TotalDeathByContinent as
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..[Covid Deaths]
Where continent is not null
Group By continent

Select * 
From TotalDeathByContinent
