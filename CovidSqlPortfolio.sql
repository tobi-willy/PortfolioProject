Select * 
from CovidDeaths
WHERE continent is not null
order by 3,4



Select * 
from CovidVaccinations
WHERE continent is not null
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
WHERE continent is not null
order by 1,2

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
from CovidDeaths
where location like 'Nigeria' and continent is not null
order by 1,2

Select location, date, population ,total_cases, (total_cases/population)* 100 as PercentPopulationInfected
from CovidDeaths
--where location like 'Nigeria' and continent is not null
order by 1,2

Select location, population ,MAX(total_cases)as HighestInfectionCount, MAX((total_cases/population))* 100 as PercentPopulationInfected
from CovidDeaths
--where and continent is not null
Group by location, population
order by 4 desc

Select location,MAX(cast(total_deaths as int)) as TotalDeathCounts
from CovidDeaths
where continent is not null
Group by location
order by 2 desc

Select continent,MAX(cast(total_deaths as int)) as TotalDeathCounts
from CovidDeaths
where continent is not null
Group by continent
order by 2 desc

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
from CovidDeaths
where continent is not null
Group by date
order by 1,2 desc

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
from CovidDeaths
where continent is not null
--Group by date
order by 1,2 desc


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CONVERT(int, vac.new_vaccinations))OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleInfected
from CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleInfected)
 as 
( Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM (CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleInfected
from CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
) 
 Select *, (RollingPeopleInfected/Population)*100
 from PopvsVac

Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM (CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
 and dea.date = vac.date
 --where dea.continent is not null
 --order by 2,3
 
 Select *, (RollingPeopleVaccinated/Population)*100
 from  #PercentPopulationVaccinated


 CREATE VIEW 
 PercentPopulationVaccinated as
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM (CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3

 Select *
 from PercentPopulationVaccinated