﻿using System;
using System.Collections.Generic;
using System.Text;
using Xamarin.Forms;

namespace TerminalSIGES.Views.Lib {
  public class BaseTabbedPage : TabbedPage {
    public bool MostrarNavegacion { get; set; }
    public bool MostrarAnimacion { get; set; }
    public BaseTabbedPage() {
      MostrarNavegacion = true;
      MostrarAnimacion = true;
      BackgroundColor = Color.FromRgb(237, 237, 237);
        
        }

    protected override void OnAppearing() {
      base.OnAppearing();
      if (!MostrarAnimacion) return;
#if __ANDROID__ 
      this.Animate("InicioAnimacion", (s) => Layout(new Rectangle(X, (1 - s) * Height, Width, Height)), 0, 480, Easing.SinOut, null, null);
#endif
      NavigationPage.SetHasNavigationBar(this, MostrarNavegacion);
    }
    protected override void OnDisappearing() {
      base.OnDisappearing();
      if (!MostrarAnimacion) return;
#if __ANDROID__ 
      this.Animate("FinAnimacion", (s) => Layout(new Rectangle(X, (s - 1) * Height, Width, Height)), 0, 480, Easing.SinIn, null, null);
#endif
    }
  }
}
