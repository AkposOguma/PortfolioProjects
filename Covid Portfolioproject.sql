Select *
from CovidDeaths
where continent is not NULL
ORDER BY 3,4


SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
order by 1,2

-- Total Cases Vs Total Deaths
SELECT Location, date, total_cases, total_deaths, (CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
order by 1,2


-- Total Cases Vs Population
-- Shows what percentage of population have got covid
SELECT Location, date,population, total_cases, (CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))*100 as PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%states%'
order by 1,2

-- Countries with highest infection rate compared to Population
SELECT Location,population, max(total_cases) as HighestInfectionCount, max(CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))*100 as PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%states%'
Group BY location,population
order by PercentPopulationInfected DESC


-- Showing Countries with Death Count per Population
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null 
Group BY location
order by TotalDeathCount DESC

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
WHERE continent is null 
Group BY location
order by TotalDeathCount DESC


-- Showing the continent with the highest death count
-- Let's break things down by continent

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null 
Group BY continent
order by TotalDeathCount DESC



-- GLOBAL NUMBERS
-- showing death percentage by date 
SELECT date, sum(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (sum(CONVERT(float,new_deaths))/nullif(sum(CONVERT(float,new_cases)),0 ))* 100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not NULL
group by date
order by 1,2

-- showing total death percentage 
SELECT sum(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (sum(CONVERT(float,new_deaths))/nullif(sum(CONVERT(float,new_cases)),0 ))* 100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not NULL
order by 1,2


-- looking at total population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
inner join CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
inner join CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
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
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
inner join CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
-- order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
inner join CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
-- order by 2,3
