within AixLib.Systems.HeatPumpSystems.Examples;
model HeatPumpSystem "Example for a heat pump system"
  import AixLib;

 extends Modelica.Icons.Example;

  AixLib.Fluid.Sources.MassFlowSource_T sourceSideMassFlowSource(
    use_T_in=true,
    m_flow=1,
    nPorts=1,
    redeclare package Medium = Modelica.Media.Water.ConstantPropertyLiquidWater,

    T=275.15) "Ideal mass flow source at the inlet of the source side"
    annotation (Placement(transformation(extent={{-54,24},{-34,44}})));

  AixLib.Fluid.Sources.FixedBoundary sourceSideFixedBoundary(redeclare package
      Medium = Modelica.Media.Water.ConstantPropertyLiquidWater, nPorts=1)
    "Fixed boundary at the outlet of the source side"
    annotation (Placement(transformation(extent={{-58,-28},{-38,-8}})));
  AixLib.Fluid.Sources.FixedBoundary sinkSideFixedBoundary(nPorts=1, redeclare
      package Medium = Modelica.Media.Water.ConstantPropertyLiquidWater)
    "Fixed boundary at the outlet of the sink side"
    annotation (Placement(transformation(extent={{110,8},{90,28}})));
  AixLib.Fluid.Sources.MassFlowSource_T sinkSideMassFlowSource(
    redeclare package Medium = Modelica.Media.Water.ConstantPropertyLiquidWater,

    m_flow=0.5,
    use_m_flow_in=true,
    nPorts=1,
    T=308.15) "Ideal mass flow source at the inlet of the sink side"
    annotation (Placement(transformation(extent={{-12,-60},{8,-40}})));
  Modelica.Blocks.Sources.Ramp TsuSourceRamp(
    duration=1000,
    startTime=1000,
    height=25,
    offset=278)
    "Ramp signal for the temperature input of the source side's ideal mass flow source"
    annotation (Placement(transformation(extent={{-94,2},{-74,22}})));
  Modelica.Blocks.Sources.Pulse massFlowPulse(
    amplitude=0.5,
    period=1000,
    offset=0,
    startTime=0,
    width=51)
    "Pulse signal for the mass flow input of the sink side's ideal mass flow source"
    annotation (Placement(transformation(extent={{-80,-60},{-60,-40}})));
  AixLib.Fluid.Sensors.TemperatureTwoPort temperature(redeclare package Medium
      = Modelica.Media.Water.ConstantPropertyLiquidWater, m_flow_nominal=
        heatPumpSystem.mFlow_conNominal)
    "Temperature sensor at the outlet of the sink side"
    annotation (Placement(transformation(extent={{56,8},{76,28}})));
  Modelica.Blocks.Interfaces.RealOutput T_Co_out
    "Temperature at the outlet of the sink side of the heat pump"
    annotation (Placement(transformation(extent={{100,40},{120,60}})));
  AixLib.Systems.HeatPumpSystems.HeatPumpSystem heatPumpSystem(
    redeclare package Medium_con =
        Modelica.Media.Water.ConstantPropertyLiquidWater,
    mFlow_conNominal=1,
    mFlow_evaNominal=1,
    VCon=1,
    VEva=1,
    dpEva_nominal=0,
    dpCon_nominal=0,
    useConPum=false,
    useEvaPum=false,
    GEva=1,
    GCon=1,
    redeclare package Medium_eva =
        Modelica.Media.Water.ConstantPropertyLiquidWater,
    use_comIne=false,
    comIneTime_constant=0,
    maxRunPerHou=2,
    CEva=8000,
    CCon=8000,
    scalingFactor=1,
    redeclare model PerfData =
        AixLib.Fluid.HeatPumps.BaseClasses.PerformanceData.LookUpTable2D (
          final dataTable=AixLib.DataBase.HeatPump.EN255.Vitocal350AWI114()),
    use_runPerHou=false,
    use_sec=true,
    use_minRunTime=true,
    use_opeEnv=true,
    use_deFro=true,
    minIceFac=0.5,
    minRunTime(displayUnit="min") = 1800,
    tableUpp=[-15,60; 35,60],
    tableLow=[-15,0; 35,0],
    use_minLocTime=true,
    minLocTime(displayUnit="min") = 3000)
    annotation (Placement(transformation(extent={{-10,-16},{16,8}})));
equation

  connect(TsuSourceRamp.y,sourceSideMassFlowSource. T_in) annotation (Line(
      points={{-73,12},{-68,12},{-68,38},{-56,38}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(massFlowPulse.y,sinkSideMassFlowSource. m_flow_in) annotation (Line(
      points={{-59,-50},{-14,-50},{-14,-42}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(sinkSideFixedBoundary.ports[1],temperature. port_b) annotation (Line(
      points={{90,18},{76,18}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(temperature.T,T_Co_out)  annotation (Line(
      points={{66,29},{66,50},{110,50}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(sinkSideMassFlowSource.ports[1], heatPumpSystem.port_a2)
    annotation (Line(points={{8,-50},{8,-16},{9.5,-16}}, color={0,127,255}));
  connect(heatPumpSystem.port_b1, temperature.port_a) annotation (Line(points={
          {9.5,8},{38,8},{38,18},{56,18}}, color={0,127,255}));
  connect(heatPumpSystem.port_a1, sourceSideMassFlowSource.ports[1])
    annotation (Line(points={{-3.5,8},{0,8},{0,34},{-34,34}}, color={0,127,255}));
  connect(heatPumpSystem.port_b2, sourceSideFixedBoundary.ports[1]) annotation
    (Line(points={{-3.5,-16},{10,-16},{10,-18},{-38,-18}}, color={0,127,255}));
  connect(TsuSourceRamp.y, heatPumpSystem.T_oda) annotation (Line(points={{-73,
          12},{-47.5,12},{-47.5,3.9},{-11.625,3.9}}, color={0,0,127}));
  annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,
            -100},{100,100}})),
    experiment(StopTime=3600),
    __Dymola_experimentSetupOutput,
    Documentation(info="<html>
<h4><span style=\"color: #008000\">Overview</span></h4>
<p>Simple test set-up for the HeatPumpDetailed model. The heat pump is turned on and off while the source temperature increases linearly. Outputs are the electric power consumption of the heat pump and the supply temperature. </p>
<p>Besides using the default simple table data, the user should also test tabulated data from <a href=\"modelica://AixLib.DataBase.HeatPump\">AixLib.DataBase.HeatPump</a> or polynomial functions.</p>
</html>",
      revisions="<html>
 <ul>
  <li>
  May 19, 2017, by Mirko Engelpracht:<br/>
  Added missing documentation (see <a href=\"https://github.com/RWTH-EBC/AixLib/issues/391\">issue 391</a>).
  </li>
  <li>
  October 17, 2016, by Philipp Mehrfeld:<br/>
  Implemented especially for comparison to simple heat pump model.
  </li>
 </ul>
</html>
"), __Dymola_Commands(file="Modelica://AixLib/Resources/Scripts/Dymola/Fluid/HeatPumps/Examples/HeatPump.mos" "Simulate and plot"));
end HeatPumpSystem;
