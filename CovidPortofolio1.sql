-- Make divide by Zero Null
SET ARITHABORT OFF 
SET ANSI_WARNINGS OFF

-- SELECT BASIC
SELECT *
FROM CovidPortofolio..CovidDeaths
ORDER BY location, date

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidPortofolio..CovidDeaths
ORDER BY location, date

-- Total Cases vs Total Deaths 
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths as int)/total_cases)*100 as DeathPercentage
FROM CovidPortofolio..CovidDeaths
WHERE location = 'Indonesia'
ORDER BY location, date

-- Total Cases vs Population
SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
FROM CovidPortofolio..CovidDeaths
WHERE location = 'Indonesia'
ORDER BY location, date

--Countries with Highest Infection Rate Compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM CovidPortofolio..CovidDeaths
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC

--Countries with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths as int)) AS  TotalDeathCount
FROM CovidPortofolio..CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Contintents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths as int)) AS  TotalDeathCount
FROM CovidPortofolio..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global numbers

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_death, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM CovidPortofolio..CovidDeaths
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidPortofolio..CovidDeaths as dea
JOIN CovidPortofolio..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- CTE
With PopvsVac (Continent, Location, Date, Population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidPortofolio..CovidDeaths as dea
JOIN CovidPortofolio..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidPortofolio..CovidDeaths as dea
JOIN CovidPortofolio..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Create View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidPortofolio..CovidDeaths as dea
JOIN CovidPortofolio..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null