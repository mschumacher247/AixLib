within AixLib.Fluid.Sensors;
model Temperature "Ideal one port temperature sensor"
    extends AixLib.Fluid.Sensors.BaseClasses.PartialAbsoluteSensor;

  Modelica.Blocks.Interfaces.RealOutput T(final quantity="ThermodynamicTemperature",
                                          final unit = "K",
                                          min=0,
                                          displayUnit = "degC")
    "Temperature in port medium"
    annotation (Placement(transformation(extent={{60,-10},{80,10}})));

equation
  T = Medium.temperature(state=Medium.setState_phX(
        p=port.p, h=inStream(port.h_outflow), X=inStream(port.Xi_outflow)));
annotation (defaultComponentName="senTem",
    Documentation(info="<html>
<p>
This model outputs the temperature of the fluid connected to its port.
The sensor is ideal, i.e., it does not influence the fluid.
</p>
<p>
Read the
<a href=\"modelica://AixLib.Fluid.Sensors.UsersGuide\">
AixLib.Fluid.Sensors.UsersGuide</a>
prior to using this model with one fluid port.
</p>
</html>",
revisions="<html>
<ul>
<li>
September 29, 2009, by Michael Wetter:<br/>
First implementation.
Implementation is based on <code>Modelica.Fluid</code>.
</li>
</ul>
</html>"),
  Diagram(coordinateSystem(preserveAspectRatio=true,  extent={{-100,-100},{100,100}}),
                        graphics={
        Line(points={{0,-70},{0,-100}}, color={0,0,127}),
        Ellipse(
          extent={{-20,-98},{20,-60}},
          lineColor={0,0,0},
          lineThickness=0.5,
          fillColor={191,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-12,40},{12,-68}},
          lineColor={191,0,0},
          fillColor={191,0,0},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-12,40},{-12,80},{-10,86},{-6,88},{0,90},{6,88},{10,86},{
              12,80},{12,40},{-12,40}},
          lineColor={0,0,0},
          lineThickness=0.5),
        Line(
          points={{-12,40},{-12,-64}},
          color={0,0,0},
          thickness=0.5),
        Line(
          points={{12,40},{12,-64}},
          color={0,0,0},
          thickness=0.5),
        Line(points={{-40,-20},{-12,-20}}, color={0,0,0}),
        Line(points={{-40,20},{-12,20}}, color={0,0,0}),
        Line(points={{-40,60},{-12,60}}, color={0,0,0}),
        Line(points={{12,0},{60,0}}, color={0,0,127})}),
    Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,
            100}}), graphics={
        Ellipse(
          extent={{-20,-88},{20,-50}},
          lineColor={0,0,0},
          lineThickness=0.5,
          fillColor={191,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-12,50},{12,-58}},
          lineColor={191,0,0},
          fillColor={191,0,0},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-12,50},{-12,90},{-10,96},{-6,98},{0,100},{6,98},{10,96},{12,
              90},{12,50},{-12,50}},
          lineColor={0,0,0},
          lineThickness=0.5),
        Line(
          points={{-12,50},{-12,-54}},
          color={0,0,0},
          thickness=0.5),
        Line(
          points={{12,50},{12,-54}},
          color={0,0,0},
          thickness=0.5),
        Line(points={{-40,-10},{-12,-10}}, color={0,0,0}),
        Line(points={{-40,30},{-12,30}}, color={0,0,0}),
        Line(points={{-40,70},{-12,70}}, color={0,0,0}),
        Text(
          extent={{126,-30},{6,-60}},
          lineColor={0,0,0},
          textString="T"),
        Text(
          extent={{-150,110},{150,150}},
          textString="%name",
          lineColor={0,0,255}),
        Line(points={{12,0},{60,0}}, color={0,0,127})}));
end Temperature;