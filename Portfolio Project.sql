SELECT * 
FROM PortfolioProject..COVIDDEATHS$ 
order by 3,4

--SELECT * FROM PortfolioProject..COVIDVACCINATIONS$ order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..COVIDDEATHS$ order by 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..COVIDDEATHS$ 
where location like '%dia'
order by 1,2

--Total cases vs Population

SELECT location, date, population, total_cases, (total_cases/population)*100 as PopPercentage
FROM PortfolioProject..COVIDDEATHS$ 
where location like '%dia'
order by 1,2

--Countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as MaximumCount, MAX(total_cases/population)*100 as MaximumPercentage
FROM PortfolioProject..COVIDDEATHS$ 
Group by location, population
order by MaximumPercentage desc

--countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as MaximumDeath
FROM PortfolioProject..COVIDDEATHS$ 
Group by location
order by MaximumDeath desc

-- death by continent

SELECT continent, MAX(cast(total_deaths as int)) as MaximumDeath
FROM PortfolioProject..COVIDDEATHS$ 
where continent is not null
Group by continent
order by MaximumDeath desc

--Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..COVIDDEATHS$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


--Total Population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..COVIDDEATHS$ dea
Join PortfolioProject..COVIDVACCINATIONS$ vac
     On dea.location =vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Use CTE


with PopvsVac (continent, location,  date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..COVIDDEATHS$ dea
Join PortfolioProject..COVIDVACCINATIONS$ vac
     On dea.location =vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (RollingPeopleVaccinated/population)*100
From PopvsVac


--Temp Table 
DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..COVIDDEATHS$ dea
Join PortfolioProject..COVIDVACCINATIONS$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..COVIDDEATHS$ dea
Join PortfolioProject..COVIDVACCINATIONS$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select * from PercentagePopulationVaccinated