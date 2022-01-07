select *
	from PortfolioProject ..covidDeaths
	order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
	from PortfolioProject ..covidDeaths
	order by 1,2

--Looking at total cases v/s total deaths--
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
	from PortfolioProject ..covidDeaths
	order by 1 ,2

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
	from PortfolioProject ..covidDeaths
	where Location like '%states%'
	order by 1,2;

--Looking at total cases v/s population --
--Shows what percentage of population got covid
select Location, date,population, total_cases, (total_cases/population)*100 AS TotalCasePercentage
	from PortfolioProject ..covidDeaths
	where Location like '%states%'
	order by 1,2;

--Looking at countries with highest Infection rate compared to population--
select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS TotalCasePercentage
	from PortfolioProject ..covidDeaths
	group by location, population
	order by TotalCasePercentage desc;

--Showing continent with highest death count  per population
select continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
	from PortfolioProject ..covidDeaths
	where continent is not NULL
	group by continent
	order by TotalDeathCount desc;

--Join both the tables
select * 
	from PortfolioProject ..covidDeaths dea
	Join PortfolioProject ..covidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date

--loooking at total population vs vaccinations

select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations, 
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
	dea.Date) as RollingPeopleVaccinated
	from PortfolioProject ..covidDeaths dea
	Join PortfolioProject ..covidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not NULL
order by 2,3;

--USE CTE
WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations, 
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
	dea.Date) as RollingPeopleVaccinated
	from PortfolioProject ..covidDeaths dea
	Join PortfolioProject ..covidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not NULL
)
Select *,(RollingPeopleVaccinated/Population)*100 from PopVSVac

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 



