using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;
using AuthModule.Models;
using System.IO;
using AuthIntegration;
using PagedList;
using Microsoft.AspNet.Identity;
using System.Threading.Tasks;
using System.Web;
using Microsoft.AspNet.Identity.Owin;
using System.Web.UI;
using System.Data.Entity.Core.EntityClient;
using System.Data.SqlClient;
using System.Data;
using System.Configuration;
using Microsoft.SqlServer.Server;
using System.Web.Helpers;


namespace AuthModule.Controllers
{
    [Authorize]
    public class HomeController : Controller
    {
        private app_authentication_devEntities db = new app_authentication_devEntities();
        private IntegrationFunctionality IntegrateDll = new IntegrationFunctionality();

        private int pageSize = 8;

        public ActionResult Index()
        {
            //if (!Request.IsAuthenticated)
            //{

            ViewBag.Role = getRole();
            string CurrentUserid = getUserId();
            //var data = IntegrateDll.IsLogin("2115826f-b98b-40e6-8175-c63f9c8e7a15");

            //string Email = User.Identity.Name;
            //setLogin(CurrentUserid, Email);
            if (Session["token"] == null)
            {
                string token = Guid.NewGuid().ToString();
                Session["token"] = token;
            }

            var AdminUser = db.AppUserValidations.Where(s => s.UserId == CurrentUserid && s.IsGlobalAdmin == 1 && s.IsAllowAccess == 1).ToList();
            if (AdminUser != null)
            {
                var AppIdList = db.AppUserValidations.Where(s => s.UserId == CurrentUserid && s.IsAllowAccess == 1).Select(t => t.AppId).ToArray();

                var Applist = db.AppRegistrations.Where(s => AppIdList.Contains(s.Id) && s.IsActive == 1 && s.AppType == 1).ToList();   //AppType==1 forAll Web App
                return View(Applist);
            }
            else
            {
                var AppIdList = db.AppUserValidations.Where(s => s.UserId == CurrentUserid && s.IsAllowAccess == 1).Select(t => t.AppId).ToArray();
                var Applist = db.AppRegistrations.Where(s => AppIdList.Contains(s.Id) && s.IsActive == 1 && s.AppType == 1).ToList(); //AppType==1 forAll Web App

                return View(Applist);
            }

        }

        public void setLogin(string userid, string Email, int AppId)   //string token,
        {
            if (Session["token"] != null)
            {
                //string token = Guid.NewGuid().ToString();
                //Session["token"] = token;
                string token = Session["token"].ToString();
                int res = IntegrateDll.Login(token, userid, AppId, Email);
            }

        }

        public int getRole()
        {
            int role = -1;
            string Email = User.Identity.Name;
            var userid = db.AspNetUsers.Where(s => s.Email == Email).Select(t => t.Id).FirstOrDefault();
            var GlobalAdmin = db.AppUserValidations.Where(s => (s.UserId == userid) && (s.IsGlobalAdmin == 1)).FirstOrDefault();
            if (GlobalAdmin != null)
            {
                role = (int)Role.GlobalAdmin;

            }
            else
            {
                var AppAdmin = db.AppUserValidations.Where(s => s.UserId == userid && s.IsAppAdmin == 1).FirstOrDefault();
                if (AppAdmin != null)
                    role = (int)Role.AppAdmin;
                else
                    role = (int)Role.User;

            }

            return role;
        }

        public string getUserId()
        {
            string Email = User.Identity.Name;
            var userid = db.AspNetUsers.Where(s => s.Email == Email).Select(t => t.Id).FirstOrDefault();
            return userid;
        }

        #region APP Management and Registration
        [HttpGet]
        public ActionResult AppRegistration()
        {
            AppRegistrationModel newApp = new AppRegistrationModel();
            ViewBag.Role = getRole();

            var list = db.AppTypes.Select(s => new
            {
                Id = s.Id,
                AppType = s.AppType1
            }).ToList();
            ViewBag.AppType = list;

            return View(newApp);
        }
        [HttpPost]
        public ActionResult AppRegistration(AppRegistrationModel model)
        {
            ViewBag.Role = getRole();
            var list = db.AppTypes.Select(s => new
            {
                Id = s.Id,
                AppType = s.AppType1
            }).ToList();
            ViewBag.AppType = list;

            try
            {

                if (model.Id != 0)
                {
                    var ExistingApp = db.AppRegistrations.Where(s => s.Id == model.Id).FirstOrDefault();
                    model.AppTypeId = (int)ExistingApp.AppType;
                    ModelState.Remove("AppTypeId");
                }
                if (model.AppTypeId == 2)
                    ModelState.Remove("Url");

                if (ModelState.IsValid)
                {
                    if (model.ImageFile != null)
                    {
                        //Use Namespace called :  System.IO  
                        string FileName = Path.GetFileNameWithoutExtension(model.ImageFile.FileName);

                        //To Get File Extension  
                        string FileExtension = Path.GetExtension(model.ImageFile.FileName);

                        //Add Current Date To Attached File Name  
                        // FileName = DateTime.Now.ToString("yyyyMMdd") + "-" + FileName.Trim() + FileExtension;

                        FileName = DateTime.Now.ToString("yyyyMMddHHmmss") + "-" + FileName.Trim() + FileExtension;

                        //Get Upload path from Web.Config file AppSettings.  
                        string UploadPath = Server.MapPath("/Image/");

                        //Its Create complete path to store in server.  
                        model.ImageName = UploadPath + FileName;

                        //To copy and save file into server.  
                        model.ImageFile.SaveAs(model.ImageName);

                        if (model.Id == 0)
                        {
                            AppRegistration newApp = new AppRegistration();
                            newApp.AppName = model.Name;
                            newApp.AppType = model.AppTypeId;

                            if (model.AppTypeId == 2)
                                model.Url = Guid.NewGuid().ToString();


                            newApp.Url = model.Url;
                            newApp.ImagePath = FileName;
                            newApp.DefaultAuthorized = Convert.ToByte(model.DefaultAuthorized);
                            newApp.IsActive = Convert.ToByte(model.IsActive);
                            db.AppRegistrations.Add(newApp);
                            db.SaveChanges();

                            if (model.DefaultAuthorized == true)
                            {
                                var App = db.AppRegistrations.Where(s => s.AppName == model.Name && s.Url == model.Url).OrderByDescending(t => t.Id).FirstOrDefault();
                                var AllUser = db.AspNetUsers.ToList();
                                foreach (var user in AllUser)
                                {
                                    setAllowAccess(user.Id, App.Id, true, "AllowAccess");
                                }
                            }
                        }
                        else
                        {
                            var ExistingApp = db.AppRegistrations.Where(s => s.Id == model.Id).FirstOrDefault();
                            ExistingApp.AppName = model.Name;
                            ExistingApp.AppType = model.AppTypeId;
                            ExistingApp.Url = model.Url;
                            ExistingApp.DefaultAuthorized = Convert.ToByte(model.DefaultAuthorized);
                            ExistingApp.IsActive = Convert.ToByte(model.IsActive);
                            ExistingApp.ImagePath = FileName;
                            db.SaveChanges();

                        }
                    }
                    else
                    {
                        if (model.Id == 0)
                        {
                            AppRegistration newApp = new AppRegistration();
                            newApp.AppName = model.Name;
                            newApp.AppType = model.AppTypeId;

                            if (model.AppTypeId == 2)
                                model.Url = Guid.NewGuid().ToString();


                            newApp.Url = model.Url;

                            newApp.DefaultAuthorized = Convert.ToByte(model.DefaultAuthorized);
                            newApp.IsActive = Convert.ToByte(model.IsActive);
                            db.AppRegistrations.Add(newApp);
                            db.SaveChanges();

                            if (model.DefaultAuthorized == true)
                            {
                                var App = db.AppRegistrations.Where(s => s.AppName == model.Name && s.Url == model.Url).OrderByDescending(t => t.Id).FirstOrDefault();
                                var AllUser = db.AspNetUsers.ToList();
                                foreach (var user in AllUser)
                                {
                                    setAllowAccess(user.Id, App.Id, true, "AllowAccess");
                                }
                            }
                        }
                        else
                        {
                            var ExistingApp = db.AppRegistrations.Where(s => s.Id == model.Id).FirstOrDefault();
                            ExistingApp.AppName = model.Name;
                            ExistingApp.AppType = model.AppTypeId;
                            ExistingApp.Url = model.Url;
                            ExistingApp.DefaultAuthorized = Convert.ToByte(model.DefaultAuthorized);
                            ExistingApp.IsActive = Convert.ToByte(model.IsActive);

                            db.SaveChanges();

                        }
                    }
                    // ModelState.AddModelError("Message", "App Successfully Registered!!");
                    if (Session["token"] != null)
                    {
                        return RedirectToAction("Index");
                    }
                    else
                    {
                        return RedirectToAction("LogOff", "Account");
                    }

                }
                else
                {
                    return View(model);
                }
            }
            catch (Exception e)
            {
                ModelState.AddModelError("Error", e.Message.ToString());

                return View(model);
            }


        }
        public ActionResult EditAppRegistration(int AppId)
        {
            ViewBag.Role = getRole();
            var list = db.AppTypes.Select(s => new
            {
                Id = s.Id,
                AppType = s.AppType1
            }).ToList();
            ViewBag.AppType = list;

            var App = db.AppRegistrations.Where(s => s.Id == AppId).Select(t => new AppRegistrationModel
            {
                Id = t.Id,
                AppTypeId = (int)t.AppType,
                Name = t.AppName,
                Url = t.Url,
                DefaultAuthorized = t.DefaultAuthorized == 0 ? false : true,
                IsActive = t.IsActive == 0 ? false : true,
                ImageName = t.ImagePath
            }).FirstOrDefault();

            return View("EditApplication", App);
        }
        public ActionResult AppRedirect(int AppId)
        {
            if (Session["token"] != null)
            {
                var App = db.AppRegistrations.Where(s => s.Id == AppId).FirstOrDefault();
                string token = Session["token"].ToString();
                if (App.Url.Contains("SalesOrder"))
                {
                    return RedirectToAction("SalesOrder", "Home");
                }

                //Add Current token in to login DB 
                string CurrentUserid = getUserId();
                string Email = User.Identity.Name;
                setLogin(CurrentUserid, Email, App.Id);


                string redirecturl = "";


                if (App.Url.Contains("?"))
                {
                    redirecturl = App.Url + "&token=" + token;
                }
                else
                {
                    redirecturl = App.Url + "?token=" + token;
                }

                return Redirect(redirecturl);
            }
            else
                return RedirectToAction("LogOff", "Account");
        }
        public ActionResult AppUserPermission(int AppId, string AppName, int? page)
        {
            ViewBag.Role = getRole();
            // int pageSize = 10;
            int pageNumber = (page ?? 1);

            ViewBag.Role = getRole();
            ViewBag.AppId = AppId;
            ViewBag.AppName = AppName;

            var Userlist = db.AspNetUsers.Select(s => new
            {
                UserId = s.Id,
                Email = s.Email,
                AppId = db.AppUserValidations.Where(t => t.UserId == s.Id && t.AppId == AppId).Select(x => x.AppId).FirstOrDefault(),
                IsGlobalAdmin = db.AppUserValidations.Where(t => t.UserId == s.Id && t.AppId == AppId).Select(x => x.IsGlobalAdmin).FirstOrDefault(),
                IsAppAdmin = db.AppUserValidations.Where(t => t.UserId == s.Id && t.AppId == AppId).Select(x => x.IsAppAdmin).FirstOrDefault(),
                IsAllowAccess = db.AppUserValidations.Where(t => t.UserId == s.Id && t.AppId == AppId).Select(x => x.IsAllowAccess).FirstOrDefault(),
            }).ToList();

            var userAppList = Userlist.Select(s => new UserValidationViewModel
            {
                UserId = s.UserId,
                Email = s.Email,
                AppId = s.AppId,
                IsGlobalAdmin = s.IsGlobalAdmin == null || s.IsGlobalAdmin == 0 ? false : true,
                IsAppAdmin = s.IsAppAdmin == null || s.IsAppAdmin == 0 ? false : true,
                IsAllowAccess = s.IsAllowAccess == null || s.IsAllowAccess == 0 ? false : true
            }).OrderBy(s => s.Email);


            return View(userAppList.ToPagedList(pageNumber, pageSize));
        }
        public ActionResult AppManagement(int? page)
        {
            //int pageSize = 10;
            int pageNumber = (page ?? 1);

            ViewBag.Role = getRole();
            string CurrentUserid = getUserId();
            var AdminUser = db.AppUserValidations.Where(s => s.UserId == CurrentUserid && s.IsGlobalAdmin == 1).FirstOrDefault();
            if (AdminUser != null)
            {
                //var Applist = db.AppRegistrations.Where(s => s.AppType == 2).Select(s => new MobileAppViewModel
                //{
                //    AppId = s.Id,
                //    AppKey = s.Url,
                //    AppName = s.AppName,
                //    AppLogo = s.ImagePath,
                //    DefaultAccess = s.DefaultAuthorized == 1 ? "Yes" : "No",
                //    IsActive = s.IsActive == 1 ? "Yes" : "No"
                //}).OrderBy(s=>s.AppId); //AppType == 2 for All Mobile App
                var Applist = db.AppRegistrations.Select(s => new AppViewModel
                {
                    AppId = s.Id,
                    AppKey = s.Url,
                    AppType = s.AppType == 1 ? "Web App" : "Mobile App",
                    AppName = s.AppName,
                    AppLogo = s.ImagePath,
                    DefaultAccess = s.DefaultAuthorized == 1 ? "Yes" : "No",
                    IsActive = s.IsActive == 1 ? "Yes" : "No"
                }).OrderByDescending(s => s.AppId);
                return View(Applist.ToPagedList(pageNumber, pageSize));
            }
            else
            {
                var AppIdList = db.AppUserValidations.Where(s => s.UserId == CurrentUserid).Select(t => t.AppId).ToArray();
                //var Applist = db.AppRegistrations.Where(s => AppIdList.Contains(s.Id) && s.IsActive == 1 && s.AppType == 2).Select(s => new MobileAppViewModel
                //{
                //    AppId = s.Id,
                //    AppKey = s.Url,
                //    AppName = s.AppName,
                //    DefaultAccess = s.DefaultAuthorized == 1 ? "Yes" : "No",
                //    IsActive = s.IsActive == 1 ? "Yes" : "No"
                //}).OrderBy(s => s.AppId);

                var Applist = db.AppRegistrations.Where(s => AppIdList.Contains(s.Id) && s.IsActive == 1).Select(s => new AppViewModel
                {
                    AppId = s.Id,
                    AppKey = s.Url,
                    AppType = s.AppType == 1 ? "Web App" : "Mobile App",
                    AppName = s.AppName,
                    DefaultAccess = s.DefaultAuthorized == 1 ? "Yes" : "No",
                    IsActive = s.IsActive == 1 ? "Yes" : "No"
                }).OrderByDescending(s => s.AppId);

                return View(Applist.ToPagedList(pageNumber, pageSize));
            }
        }
        public string setAllowAccess(string userid, int Appid, bool IsAllow, string Opr)
        {
            try
            {
                var AppUser = db.AppUserValidations.Where(s => s.AppId == Appid && s.UserId == userid).FirstOrDefault();
                if (AppUser == null)
                {
                    AppUserValidation newAppUser = new AppUserValidation();
                    newAppUser.UserId = userid;
                    newAppUser.AppId = Appid;
                    newAppUser.IsGlobalAdmin = 0;
                    if (Opr == "AllowAccess")
                    {
                        newAppUser.IsAllowAccess = Convert.ToByte(IsAllow);
                        newAppUser.IsAppAdmin = 0;
                    }
                    else
                    {
                        newAppUser.IsAppAdmin = Convert.ToByte(IsAllow);
                        newAppUser.IsAllowAccess = 0;
                    }
                    db.AppUserValidations.Add(newAppUser);
                }
                else
                {
                    if (Opr == "AllowAccess")
                    {
                        AppUser.IsAllowAccess = Convert.ToByte(IsAllow);
                    }
                    else
                    {
                        AppUser.IsAppAdmin = Convert.ToByte(IsAllow);
                    }
                }
                db.SaveChanges();
                return "1";
            }
            catch (Exception e)
            {
                return e.Message.ToString();
            }

        }

        #endregion



        #region UserRegistration By Admin

        public ActionResult UserRegister()
        {
            ViewBag.Role = getRole();
            return View();
        }

        //
        // POST: /Account/Register
        [HttpPost]
        //[AllowAnonymous]
        [ValidateAntiForgeryToken]
        public async Task<ActionResult> UserRegister(RegisterViewModel model)
        {
            ViewBag.Role = getRole();
            if (ModelState.IsValid)
            {

                var user = new ApplicationUser { UserName = model.Email, Email = model.Email, Hometown = model.Hometown };
                var usermanager = System.Web.HttpContext.Current.GetOwinContext().GetUserManager<ApplicationUserManager>();

                var result = await usermanager.CreateAsync(user, model.Password);
                if (result.Succeeded)
                {
                    string code = await usermanager.GenerateEmailConfirmationTokenAsync(user.Id);
                    var callbackUrl = Url.Action("ConfirmEmail", "Account", new { userId = user.Id, code = code }, protocol: Request.Url.Scheme);
                    await usermanager.SendEmailAsync(user.Id, "Confirm your account", "Please confirm your account by clicking <a href=\"" + callbackUrl + "\">here</a>");



                    var ExistUserValidation = db.AppUserValidations.Where(s => s.UserId == user.Id).FirstOrDefault();
                    if (ExistUserValidation == null)
                    {
                        var applist = db.AppRegistrations.Select(s => new
                        {
                            Appid = s.Id,
                            Name = s.AppName,
                            DefaultAuth = s.DefaultAuthorized
                        }).ToList();

                        foreach (var item in applist)
                        {
                            AppUserValidation newAppUser = new AppUserValidation();
                            newAppUser.UserId = user.Id;
                            newAppUser.AppId = item.Appid;
                            newAppUser.IsGlobalAdmin = 0;
                            newAppUser.IsAppAdmin = 0;

                            if (item.DefaultAuth == 1)
                                newAppUser.IsAllowAccess = 1;
                            else
                                newAppUser.IsAllowAccess = 0;

                            db.AppUserValidations.Add(newAppUser);
                            db.SaveChanges();
                        }
                    }


                    string message = "Account confirmation mail has been sent, please verify before login !!";
                    ModelState.AddModelError("Error", message);
                }
                else
                {
                    ModelState.AddModelError("Error", result.Errors.FirstOrDefault());
                }

            }

            // If we got this far, something failed, redisplay form
            return View(model);
        }

        #endregion

        #region Device management
        public ActionResult DeviceManagement(int? page)
        {
            //int pageSize = 10;
            int pageNumber = (page ?? 1);

            ViewBag.Role = getRole();
            string CurrentUserid = getUserId();
            var DeviceList = db.UserDeviceRegistrations.Where(z => z.IsDeleted == false).Select(s => new DeviceViewModel
            {
                Id = s.Id,
                UserId = s.UserID,
                Email = s.Email,
                AppId = s.AppID,
                Appname = db.AppRegistrations.Where(a => a.Id == s.AppID).Select(an => an.AppName).FirstOrDefault(),
                DeviceId = s.DeviceID,
                DeviceOs = s.DeviceOs,
                DeviceVersion = s.DeviceOsVersion,
                Devicename = s.DeviceName,
                IsActive = s.IsActive
            }).OrderBy(o => o.Id);

            return View(DeviceList.ToPagedList(pageNumber, pageSize));
        }

        public ActionResult EnableDisableDevice(int Id, bool? Isactive, int? pageNumber)
        {
            var Device = db.UserDeviceRegistrations.Where(d => d.Id == Id).FirstOrDefault();
            if (Device != null)
            {
                Device.IsActive = Isactive;
                db.SaveChanges();
            }
            return RedirectToAction("DeviceManagement");
        }

        public ActionResult deleteDevice(int Id)
        {
            var Device = db.UserDeviceRegistrations.Where(d => d.Id == Id).FirstOrDefault();
            if (Device != null)
            {
                Device.IsDeleted = true;
                db.SaveChanges();
            }
            return RedirectToAction("DeviceManagement");
        }


        //public void LoginHistory(int Id)
        //{
        //    var Device = db.UserDeviceRegistrations.Where(d => d.Id == Id).FirstOrDefault();
        //}

        #endregion

        #region Profile Management


        public ActionResult changePassword()
        {
            return View();
        }
        [HttpPost]
        //public async Task<ActionResult> changePassword(ChangePasswordViewModel model)
        //{
        //    //if (!ModelState.IsValid)
        //    //{
        //    //    return View(model);
        //    //}
        //    ////var user = await UserManager.FindByNameAsync(model.Email);
        //    //if (user == null)
        //    //{
        //    //    // Don't reveal that the user does not exist
        //    //    return RedirectToAction("ResetPasswordConfirmation", "Account");
        //    //}
        //    //var result = await UserManager.ResetPasswordAsync(user.Id, model.Code, model.Password);
        //    //if (result.Succeeded)
        //    //{
        //    //    return RedirectToAction("ResetPasswordConfirmation", "Account");
        //    //}
        //    //AddErrors(result);
        //    return View();
        //}

        //#endregion

        //#region Helper

        //private void AddErrors(IdentityResult result)
        //{
        //    foreach (var error in result.Errors)
        //    {
        //        ModelState.AddModelError("", error);
        //    }
        //}
        //#endregion

        //#region Sales Order
        //public ActionResult SalesOrder()
        //{

        //    ViewBag.Role = getRole();
        //    string CurrentUserid = getUserId();
        //    var AdminUser = db.AppUserValidations.Where(s => s.UserId == CurrentUserid && s.IsGlobalAdmin == 1).FirstOrDefault();
        //    SalesOrderViewModel salesOrderViewModel = new SalesOrderViewModel();
        //    if (TempData["OD"] != null)
        //    {
        //        string Od = TempData["OD"].ToString();
        //        ViewBag.Od = Od;
        //    }
        //    return View();

        //}
        //[HttpPost]
        //public ActionResult SalesOrder(SalesOrderViewModel salesOrderViewModel)
        //{

        //    ViewBag.Role = getRole();
        //    string CurrentUserid = getUserId();
        //    var AdminUser = db.AppUserValidations.Where(s => s.UserId == CurrentUserid && s.IsGlobalAdmin == 1).FirstOrDefault();
        //    SalesOrderViewModel salesOrderObj = new SalesOrderViewModel();
        //    salesOrderObj = salesOrderViewModel;
        //    return View();

        //}

        //#endregion
        //#region Sales Order Spanish
        //public ActionResult SalesOrderSpanish()
        //{

        //    ViewBag.Role = getRole();
        //    string CurrentUserid = getUserId();
        //    var AdminUser = db.AppUserValidations.Where(s => s.UserId == CurrentUserid && s.IsGlobalAdmin == 1).FirstOrDefault();
        //    SalesOrderViewModel salesOrderViewModel = new SalesOrderViewModel();
        //    if (TempData["OD"] != null)
        //    {
        //        string Od = TempData["OD"].ToString();
        //        ViewBag.Od = Od;
        //    }
        //    return View();

        //}
        //[HttpPost]
        //public ActionResult SalesOrderSpanish(SalesOrderViewModel salesOrderViewModel)
        //{

        //    ViewBag.Role = getRole();
        //    string CurrentUserid = getUserId();
        //    var AdminUser = db.AppUserValidations.Where(s => s.UserId == CurrentUserid && s.IsGlobalAdmin == 1).FirstOrDefault();
        //    SalesOrderViewModel salesOrderObj = new SalesOrderViewModel();
        //    salesOrderObj = salesOrderViewModel;
        //    return View();

        //}

        //#endregion

        //#region Price Selection
        //public ActionResult ProductSelection1()
        //{

        //    ViewBag.Role = getRole();
        //    string CurrentUserid = getUserId();
        //    IEnumerable<vw_tblCategory> categoryList = db.Database.SqlQuery
        //                                                                      <vw_tblCategory>("exec spGetCategoryList ").ToList();
        //    var list = categoryList.Select(s => new
        //    {
        //        Id = s.CatId,
        //        CategoryName = s.Category
        //    }).ToList();
        //    ViewBag.CatList = list;
        //    return View();

        //}
        //public ActionResult ProductSelection(string OrderId)
        //{

        //    ViewBag.Role = getRole();
        //    string CurrentUserid = getUserId();
        //    IEnumerable<vw_tblCategory> categoryList = db.Database.SqlQuery
        //                                                                      <vw_tblCategory>("exec spGetCategoryList ").ToList();
        //    var list = categoryList.Select(s => new
        //    {
        //        Id = s.CatId,
        //        CategoryName = s.Category
        //    }).ToList();
        //    ViewBag.CatList = list;
        //    if (OrderId != "New" && OrderId != "0")
        //    {
        //        IEnumerable<tblOrder> orderlist = db.Database.SqlQuery
        //                                                                        <tblOrder>("exec spGetOrderDetailsByOrderId @OrderID={0} ", OrderId).ToList();
        //    }
        //    return View();

        //}
        //public ActionResult ProductList()
        //{

        //    ViewBag.Role = getRole();
        //    string CurrentUserid = getUserId();

        //    ViewBag.ALL = "0";
        //    var list = db.tblCategories.Select(s => new
        //    {
        //        Id = s.CatId,
        //        CategoryName = s.Category
        //    }).ToList();
        //    ViewBag.CatList = list;
        //    IEnumerable<vw_tblCategory> categoryList = db.Database.SqlQuery
        //                                                                      <vw_tblCategory>("exec spGetCategoryList ").Select(s => new vw_tblCategory { CatId = s.CatId, Category = s.Category }).ToList();
        //    ViewBag.CatList = categoryList;
        //    List<tblProduct> tp = new List<tblProduct>();
        //    IEnumerable<vw_tblProducts> productList = db.Database.SqlQuery
        //                                                                      <vw_tblProducts>("exec spGetProductList ").ToList();

        //    return View(productList);

        //}
        //public ActionResult CategoryList()
        //{

        //    ViewBag.Role = getRole();
        //    string CurrentUserid = getUserId();

        //    ViewBag.ALL = "0";
        //    List<tblProduct> tp = new List<tblProduct>();
        //    IEnumerable<vw_tblCategory> categoryList = db.Database.SqlQuery
        //                                                                      <vw_tblCategory>("exec spGetCategoryList ").ToList();

        //    return View(categoryList);

        //}
        //public JsonResult Prdlist()
        //{
        //    IEnumerable<vw_tblProducts> productList = db.Database.SqlQuery
        //                                                                     <vw_tblProducts>("exec spGetProductList ").ToList();
        //    return Json(productList, JsonRequestBehavior.AllowGet);
        //}
        //public JsonResult Prdlist123(string OrderId)
        //{
        //    if (OrderId != "New" && OrderId != "0")
        //    {
        //        IEnumerable<vw_tblProducts> SelectedproductList = db.Database.SqlQuery
        //                                                                    <vw_tblProducts>("exec spGetOrderDetailsByOrderId @OrderID={0} ", OrderId).ToList();
        //        return Json(SelectedproductList, JsonRequestBehavior.AllowGet);
        //    }
        //    return Json("", JsonRequestBehavior.AllowGet);
        //}
        //public JsonResult Catlist()
        //{
        //    IEnumerable<vw_tblCategory> categoryList = db.Database.SqlQuery
        //                                                                      <vw_tblCategory>("exec spGetCategoryList ").ToList();
        //    var list = categoryList.Select(s => new
        //    {
        //        Id = s.CatId,
        //        CategoryName = s.Category
        //    }).ToList();
        //    ViewBag.CatList = list;
        //    return Json(categoryList, JsonRequestBehavior.AllowGet);
        //}

        //[HttpPost]
        //public string SaveProducts(string ProductName, string Code, string Price, string Active, string CatId, string PrdMfCode, string PrdESPDesc, string PrdTaxable)
        //{
        //    string CurrentUserid = getUserId();
        //    if (!string.IsNullOrEmpty(ProductName) && !string.IsNullOrEmpty(Code) && !string.IsNullOrEmpty(Price))
        //    {
        //        try
        //        {
        //            int count = db.Database.ExecuteSqlCommand("exec sp_I_tblProducts @PrdCode={0},@PrdDesc={1},@PrdPrice={2},@Active={3},@CMBy={4},@CatId={5},@PrdMfCode={6},@PrdESPDesc={7},@PrdTaxable={8}", Code, ProductName, Price, Active, CurrentUserid, CatId, PrdMfCode, PrdESPDesc, PrdTaxable);

        //        }
        //        catch (Exception ex)
        //        {
        //            string error = ex.Message.ToString();
        //            throw;
        //        }
        //        return "1";
        //    }
        //    else
        //    {
        //        ViewBag.ALL = "1";
        //        return "0";
        //    }
        //    // int count = db.Database.ExecuteSqlCommand("exec sp_I_tblProducts @PrdCode = " + Code + ",@PrdDesc = " + ProductName + ",@PrdPrice=" + Convert.ToDecimal(Price) + ",@Active = " + Convert.ToInt32(Active) + ",@CMBy=" + CurrentUserid);
        //    //string ConnectionString = (db.Connection as EntityConnection).StoreConnection.ConnectionString;
        //    //SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder(ConnectionString);
        //    //builder.ConnectTimeout = 2500;
        //    //SqlConnection con = new SqlConnection(builder.ConnectionString);
        //    //System.Data.Common.DbDataReader sqlReader;
        //    //con.Open();
        //    //using (SqlCommand cmd = con.CreateCommand())
        //    //{
        //    //    cmd.CommandText = "sp_I_tblProducts";
        //    //    cmd.CommandType = System.Data.CommandType.StoredProcedure;
        //    //    cmd.CommandTimeout = 0;
        //    //    cmd.Parameters.Add(new SqlParameter("@PrdCode", SqlDbType.VarChar) { Value = Code });
        //    //    sqlReader = (System.Data.Common.DbDataReader)cmd.ExecuteReader();
        //    //}


        //    //return "0";
        //}

        ////[HttpPost]
        ////public string UpdateProducts(string PrdId, string ProductName, string Code, string Price, string Active, string CatId, string PrdMfCode, string PrdESPDesc, string PrdTaxable)
        ////{
        ////    string CurrentUserid = getUserId();
        ////    if (!string.IsNullOrEmpty(ProductName) && !string.IsNullOrEmpty(Code) && !string.IsNullOrEmpty(Price))
        ////    {
        ////        try
        ////        {
        ////            int count = db.Database.ExecuteSqlCommand("exec sp_I_tblProducts @PrdCode={0},@PrdDesc={1},@PrdPrice={2},@Active={3},@CMBy={4},@PrdId={5},@CatId={6},@PrdMfCode={7},@PrdESPDesc={8},@PrdTaxable={9}", Code, ProductName, Price, Active, CurrentUserid, PrdId, CatId, PrdMfCode, PrdESPDesc, PrdTaxable);

        ////        }
        ////        catch (Exception ex)
        ////        {
        ////            string error = ex.Message.ToString();
        ////            throw;
        ////        }
        ////        return "1";
        ////    }
        ////    else
        ////    {
        ////        ViewBag.ALL = "1";
        ////        return "0";
        ////    }


        ////    return "0";
        ////}

        ////public string DeleteProducts(string PrdId)
        ////{
        ////    string CurrentUserid = getUserId();
        ////    if (!string.IsNullOrEmpty(PrdId))
        ////    {
        ////        try
        ////        {
        ////            int count = db.Database.ExecuteSqlCommand("exec sp_I_tblProducts @PrdId={0},@Delete={1}", PrdId.Trim(), 1);

        ////        }
        ////        catch (Exception ex)
        ////        {
        ////            string error = ex.Message.ToString();
        ////            throw;
        ////        }
        ////        return "1";
        ////    }
        ////    else
        ////    {
        ////        ViewBag.ALL = "1";
        ////        return "0";
        ////    }


        ////    return "0";
        ////}
        //[HttpPost]
        //public string SaveCategory(string Category, string CatDesc)
        //{
        //    string CurrentUserid = getUserId();
        //    if (!string.IsNullOrEmpty(Category))
        //    {
        //        try
        //        {
        //            int count = db.Database.ExecuteSqlCommand("exec sp_I_tblCategory @Category={0},@CatDesc={1},@CMBy={2}", Category, CatDesc, CurrentUserid);

        //        }
        //        catch (Exception ex)
        //        {
        //            string error = ex.Message.ToString();
        //            return "0";
        //        }
        //        return "1";
        //    }
        //    else
        //    {
        //        ViewBag.ALL = "1";
        //        return "0";
        //    }



        //    //return "0";
        //}
        //[HttpPost]
        ////public string UpdateCategory(string CatId, string Category, string CatDesc)
        ////{
        ////    string CurrentUserid = getUserId();
        ////    if (!string.IsNullOrEmpty(CatId) && !string.IsNullOrEmpty(Category))
        ////    {
        ////        try
        ////        {
        ////            int count = db.Database.ExecuteSqlCommand("exec sp_I_tblCategory @CatId={0},@Category={1},@CatDesc={2},@CMBy={3}", CatId, Category, CatDesc, CurrentUserid);

        ////        }
        ////        catch (Exception ex)
        ////        {
        ////            string error = ex.Message.ToString();
        ////            throw;
        ////        }
        ////        return "1";
        ////    }
        ////    else
        ////    {
        ////        ViewBag.ALL = "1";
        ////        return "0";
        ////    }


        ////    return "0";
        ////}
        ////public string DeleteCategory(string CatId)
        ////{
        ////    string CurrentUserid = getUserId();
        ////    if (!string.IsNullOrEmpty(CatId))
        ////    {
        ////        try
        ////        {
        ////            int count = db.Database.ExecuteSqlCommand("exec sp_I_tblCategory @CatId={0},@Delete={1}", CatId.Trim(), 1);

        ////        }
        ////        catch (Exception ex)
        ////        {
        ////            string error = ex.Message.ToString();
        ////            throw;
        ////        }
        ////        return "1";
        ////    }
        ////    else
        ////    {
        ////        ViewBag.ALL = "1";
        ////        return "0";
        ////    }


        ////    return "0";
        ////}
        ////[HttpPost]
        //public string SaveOrder(List<tblProduct> products, string CustId)
        //{
        //    string CurrentUserid = getUserId();
        //    Guid Od = Guid.NewGuid();
        //    if (products != null && products.Count > 0)
        //    {
        //        if (products[0].PrdESPDesc == null || products[0].PrdESPDesc == "New" || products[0].PrdESPDesc == "0")
        //        {


        //            string OrderId = Od.ToString();
        //            String strConnString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;
        //            SqlConnection con = new SqlConnection(strConnString);
        //            SqlCommand cmd = new SqlCommand();
        //            cmd.CommandType = CommandType.StoredProcedure;
        //            cmd.CommandText = "sp_I_tblOrder";
        //            cmd.Parameters.Add("@OrderId", SqlDbType.VarChar).Value = OrderId;
        //            cmd.Parameters.Add("@CustId", SqlDbType.Int).Value = Convert.ToInt32(products[0].PrdEngDesc);
        //            cmd.Parameters.Add("@DeliveryZip", SqlDbType.VarChar).Value = "12345";
        //            cmd.Parameters.Add("@CMBy", SqlDbType.VarChar).Value = CurrentUserid;

        //            cmd.Connection = con;
        //            try
        //            {
        //                con.Open();
        //                cmd.ExecuteNonQuery();


        //            }
        //            catch (Exception ex)
        //            {
        //                throw ex;
        //            }
        //            finally
        //            {
        //                con.Close();
        //                con.Dispose();
        //            }
        //        }
        //        else
        //        {
        //            Od = new Guid(products[0].PrdESPDesc);
        //        }
        //        if (!string.IsNullOrEmpty(CurrentUserid))
        //        {
        //            try
        //            {
        //                int count = 0;

        //                List<tblProduct> tp = new List<tblProduct>();
        //                tp = products;


        //                foreach (tblProduct product in tp)
        //                {
        //                    count = db.Database.ExecuteSqlCommand("exec sp_I_tblOrderItems @PrdId={0},@Qty={1},@OrderBy={2},@OrderId={3}", product.PrdId, product.quantity, CurrentUserid, Od.ToString());

        //                }

        //            }
        //            catch (Exception ex)
        //            {
        //                string error = ex.Message.ToString();
        //                return "0";
        //            }
        //            TempData["OD"] = Od.ToString();
        //            return Od.ToString();
        //        }
        //        else
        //        {
        //            ViewBag.ALL = "1";
        //            return "0";
        //        }

        //    }
        //    else
        //    {
        //        return "0";
        //    }

        //    //return "0";
        //}
        #endregion
        //[HttpPost]
        public string SaveCustomer(tblCustomer customer)
        {
            string CurrentUserid = getUserId();
            if (!string.IsNullOrEmpty(customer.CustEmail))
            {
                try
                {
                    int count = db.Database.ExecuteSqlCommand("exec sp_I_tblCustomer @CustEmail={0},@CustFN={1},@CustLN={2},@CustPhn={3},@CustMbl={4},@CustStreet={5},@CustCity={6},@CustPOAddress={7},@CustState={8},@CustCountry={9},@CustZipCode={10}",
                        customer.CustEmail, customer.CustFN, customer.CustLN, customer.CustPhn, customer.CustMbl, customer.CustStreet, customer.CustCity, customer.CustPOAddress, customer.CustState, customer.CustCountry, customer.CustZipCode);

                }
                catch (Exception ex)
                {
                    string error = ex.Message.ToString();
                    return "0";
                }
                return "1";
            }
            else
            {
                ViewBag.ALL = "1";
                return "0";
            }



            //return "0";
        }


        public JsonResult GetCustomerByEmail1(string Email)
        {
            IEnumerable<tblCustomer> productList = db.Database.SqlQuery
                                                                             <tblCustomer>("exec spGetCustomer  @CustEmail={0}", Email.Trim()).ToList();
            return Json(productList, JsonRequestBehavior.AllowGet);
        }

        public JsonResult GetOrderDetailsByCustId(string CustId)
        {
            IEnumerable<tblOrder> orderList = db.Database.SqlQuery
                                                                             <tblOrder>("exec spGetOrderDetailsByCustId  @CustId={0}", Convert.ToInt32(CustId.Trim())).ToList();

            var list = orderList.Select(s => new
            {
                OrderId = s.OrderId

            }).ToList();
            ViewBag.OrderList = list;
            return Json(orderList, JsonRequestBehavior.AllowGet);
        }
        public JsonResult GetProdcutTotalByOrderId(string OrderId)
        {
            //string Count = db.Database.SqlQuery<string>("exec sp_getProdcutTotalByOrderId  @OrderId={0}", OrderId).ToString();
            string total = "0";
            if (OrderId != "0" && OrderId != "New")
            {
                string sql = "exec sp_getProdcutTotalByOrderId  @OrderId='" + OrderId + "'";
                total = db.Database.SqlQuery<string>(sql).First();
            }
            return Json(total, JsonRequestBehavior.AllowGet);
        }

        public ActionResult MaintenanceAgreement()
        {
            return View();
        }
        public JsonResult GetCreditAppDdwnData()
        {
            IEnumerable<CredtAppDdwn> credtAppDdwnlist = db.Database.SqlQuery
                                                                             <CredtAppDdwn>("exec spCrudCreditAppddwn").ToList();


            return Json(credtAppDdwnlist, JsonRequestBehavior.AllowGet);
        }
        public ActionResult CreditAppDDList()
        {          

            ViewBag.ALL = "0";
            List<CredtAppDdwn> tp = new List<CredtAppDdwn>();
            IEnumerable<CredtAppDdwn> credtAppDdwnList = db.Database.SqlQuery
                                                                              <CredtAppDdwn>("exec spCrudCreditAppddwn ").ToList();

            return View(credtAppDdwnList);

        }
        [HttpPost]
        public string SaveCreditAppDD(string CreditAppDesc)
        {
            string CurrentUserid = getUserId();
            if (!string.IsNullOrEmpty(CreditAppDesc))
            {
                try
                {
                    int count = db.Database.ExecuteSqlCommand("exec spCrudCreditAppddwn @Insert = 1,@CreditAppName={0}", CreditAppDesc);

                }
                catch (Exception ex)
                {
                    string error = ex.Message.ToString();
                    return "0";
                }
                return "1";
            }
            else
            {
                ViewBag.ALL = "1";
                return "0";
            }
            //return "0";
        }
        [HttpPost]
        public string UpdateCreditAppDD(string CatId, string Category, string CatDesc)
        {
            string CurrentUserid = getUserId();
            if (!string.IsNullOrEmpty(CatId) && !string.IsNullOrEmpty(Category))
            {
                try
                {
                    int count = db.Database.ExecuteSqlCommand("exec sp_I_tblCategory @CatId={0},@Category={1},@CatDesc={2},@CMBy={3}", CatId, Category, CatDesc, CurrentUserid);

                }
                catch (Exception ex)
                {
                    string error = ex.Message.ToString();
                    throw;
                }
                return "1";
            }
            else
            {
                ViewBag.ALL = "1";
                return "0";
            }


            return "0";
        }
        public string DeleteCreditAppDD(string Id)
        {
            string CurrentUserid = getUserId();
            if (!string.IsNullOrEmpty(Id))
            {
                try
                {
                    int count = db.Database.ExecuteSqlCommand("exec spCrudCreditAppddwn @Id={0},@Insert=2", Id.Trim());

                }
                catch (Exception ex)
                {
                    string error = ex.Message.ToString();
                    throw;
                }
                return "1";
            }
            else
            {
                ViewBag.ALL = "1";
                return "0";
            }


            return "0";
        }

        [HttpPost]
        public string SavePayments(tblPayments payments)
        {

            //if (payments.PmtAmt != null)
            //{
            try
            {
                int count = db.Database.ExecuteSqlCommand("exec sp_I_tblPayments @OrderId={0},@PmtType={1},@PmtAmt={2},@PmtRef={3},@PmtNote={4},@PmtDate={5}",
                    payments.OrderId, Convert.ToInt32(payments.PmtType), Convert.ToDecimal(payments.PmtAmt), payments.PmtRef, payments.PmtNote, payments.PmtDate);

            }
            catch (Exception ex)
            {
                string error = ex.Message.ToString();
                return "0";
            }
            return "1";
            //}
            //else
            //{               
            //    return "0";
            //}



            //return "0";
        }

        public JsonResult GetPaymentsByOrderId(string OrderId)
        {
            IEnumerable<tblPayments> productList = db.Database.SqlQuery
                                                                             <tblPayments>("exec spGetPaymentsByOrderId  @OrderId={0}", OrderId.Trim()).ToList();
            return Json(productList, JsonRequestBehavior.AllowGet);
        }
        public ActionResult Reservations()
        {
            IEnumerable<tblLocationType> locationTypesList = db.Database.SqlQuery
                                                                             <tblLocationType>("select * from udfGetRsvtnlctntyp()").ToList();



            ViewBag.TypeList = locationTypesList;
            IEnumerable<tblLocations> locationList = db.Database.SqlQuery
                                                                           <tblLocations>("select * from udfGetLocations()").ToList();
            ViewBag.locationList = locationList;
            string rsrvtnId = Guid.NewGuid().ToString();
            ViewBag.ReservationId = rsrvtnId;
            return View();
        }
        public JsonResult GetHotelsList() 
        {
            IEnumerable<vwHotels> hotelsList = db.Database.SqlQuery
                                                                             <vwHotels>("select * from udfGetHotels() order by htl_srt_ordr").ToList();
            return Json(hotelsList, JsonRequestBehavior.AllowGet);
        }
        public JsonResult GetShipsList() 
        {
                IEnumerable<vwShips> shipsList = db.Database.SqlQuery
                                                                                 <vwShips>("select * from udfGetShips() order by ShipName").ToList();
                return Json(shipsList, JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public string SaveReservationFrm(iVwRsrvtnFrm obj)
        {
           
            
            try
            {
                // int count = db.Database.ExecuteSqlCommand("exec sp_I_VwRsrvtnFrm @htl_id = {0},@htl_nme = {1} , @htl_clrk = {2}, @htl_rsrvtn_nmbr = {3}, @shp_id = {4}, @shp_nme = {5}, @shp_dt = {6} , @shp_fc = {7}, @shp_pd = {8}, @shp_cst = {9}, @rsrvtn_ctgry = {10}, @rsrvtn_type = {11}, @gst_nme = {12}, @gst_eml = {13}, @gst_cphn1={14} , @gst_cphn2 ={15}, @arrvl_dt ={16}, @arrvl_tm ={17}, @arrvl_arprt ={18}, @arrvl_arln ={19}, @arrvl_flght_nmbr ={20}, @arrvl_nmbr_pssngrs ={21}, @arrvl_pckup_tm ={22},@arrvl_drpoff_loc ={23}, @dep_dt ={24}, @dep_tm ={25}, @dep_arprt ={26}, @dep_arln ={27}, @dep_flght_nmbr ={28}, @dep_nmbr_pssngrs ={29}, @dep_pckup_tm ={30}, @dep_drpoff_loc ={31}, @whlchr ={32}, @whlchr_cnfld ={33}, @addtnl_inf ={34}",
                //Convert.ToInt32(obj.htl_id), obj.htl_nme, obj.htl_clrk, obj.htl_rsrvtn_nmbr, Convert.ToInt32(obj.shp_id), obj.shp_nme, obj.shp_dt, obj.shp_fc, Convert.ToInt32(obj.shp_pd), Convert.ToDecimal(obj.shp_cst)
                // , Convert.ToInt32(obj.rsrvtn_ctgry), Convert.ToInt32(obj.rsrvtn_type), obj.gst_nme, obj.gst_eml, obj.gst_cphn1, obj.gst_cphn2, obj.arrvl_dt, obj.arrvl_tm, obj.arrvl_arprt, obj.arrvl_arln
                // , obj.arrvl_flght_nmbr, Convert.ToInt32(obj.arrvl_nmbr_pssngrs), obj.arrvl_pckup_tm, obj.arrvl_drpoff_loc, obj.dep_dt, obj.dep_tm, obj.dep_arprt, obj.dep_arln
                // , obj.dep_flght_nmbr, Convert.ToInt32(obj.dep_nmbr_pssngrs), obj.dep_pckup_tm, obj.dep_drpoff_loc, obj.whlchr, obj.whlchr_cnfld, obj.addtnl_inf);
                string Email = User.Identity.Name;
                int count = db.Database.ExecuteSqlCommand("exec sp_I_VwRsrvtnFrm @htl_id = {0},@htl_nme = {1} , @htl_clrk = {2}, @htl_rsrvtn_nmbr = {3}, @shp_id = {4}, @shp_nme = {5}, @shp_dt = {6} , @shp_fc = {7}, @shp_pd = {8}, @shp_cst = {9}, @rsrvtn_type = {11},@rsrvtn_nbr={35}, @gst_fnme = {35},@gst_lnme = {36}, @gst_eml = {13}, @gst_cphn1={14} , @gst_cphn2 ={15}, @arrvl_dt ={16}, @arrvl_tm ={17}, @arrvl_arprt ={18}, @arrvl_arln ={19}, @arrvl_flght_nmbr ={20}, @arrvl_nmbr_pssngrs ={21}, @arrvl_pckup_tm ={22},@arrvl_drpoff_loc ={23}, @dep_dt ={24}, @dep_tm ={25}, @dep_arprt ={26}, @dep_arln ={27}, @dep_flght_nmbr ={28}, @dep_nmbr_pssngrs ={29}, @dep_pckup_tm ={30}, @dep_drpoff_loc ={31}, @whlchr ={32}, @whlchr_cnfld ={33}, @addtnl_inf ={34},@CreatedBy = {36}",
               obj.htl_id, obj.htl_nme, obj.htl_clrk, obj.htl_rsrvtn_nmbr,obj.shp_id, obj.shp_nme, obj.shp_dt, obj.shp_fc, obj.shp_pd, obj.shp_cst
                , obj.rsrvtn_ctgry, obj.rsrvtn_type, obj.gst_nme, obj.gst_eml, obj.gst_cphn1, obj.gst_cphn2, obj.arrvl_dt, obj.arrvl_tm, obj.arrvl_arprt, obj.arrvl_arln
                , obj.arrvl_flght_nmbr, obj.arrvl_nmbr_pssngrs, obj.arrvl_pckup_tm, obj.arrvl_drpoff_loc, obj.dep_dt, obj.dep_tm, obj.dep_arprt, obj.dep_arln
                , obj.dep_flght_nmbr, obj.dep_nmbr_pssngrs, obj.dep_pckup_tm, obj.dep_drpoff_loc, obj.whlchr, obj.whlchr_cnfld, obj.addtnl_inf,obj.gst_fnme,obj.gst_lnme,obj.rsrvtn_nbr, Email);
            }
            catch (Exception ex)
            {
                string error = ex.Message.ToString();
                return "0";
            }
            return "1";



        }
        public JsonResult GetLocationTypes()
        {
            IEnumerable<tblLocationType> locationTypesList = db.Database.SqlQuery
                                                                           <tblLocationType>("select * from udfGetLocationTypes()").ToList();

            return Json(locationTypesList, JsonRequestBehavior.AllowGet);
        }
        public ActionResult LocationTypes()
        {
            IEnumerable<tblLocationType> locationTypesList = db.Database.SqlQuery
                                                                            <tblLocationType>("select * from udfGetLocationTypes()").ToList();
            
            return View(locationTypesList);
        }
        [HttpGet]
        public ActionResult EditLocationType(int typeId)
        {
            
            tblLocationType locationTypesList = db.Database.SqlQuery
                                                                            <tblLocationType>("select * from udfGetLocationTypes() where lctn_tpe_Id = {0}  ", typeId).FirstOrDefault();

            return View(locationTypesList);           
        }
        [HttpGet]
        public ActionResult AddLocationType(string type)
        {
            string loctionType = type;
            if (type == "" || type== null) 
            {
                tblLocationType locationTypesList = new tblLocationType();
                return View("EditLocationType", locationTypesList);
            }
            return View();
        }
        [HttpPost]
        public ActionResult EditLocationType(tblLocationType data)
        {
            try
            {
                int count = db.Database.ExecuteSqlCommand("exec sp_I_tblLctnTpe @lctn_tpe={0},@lctn_tpe_dsc={1},@lctn_tpe_active={2},@lctn_tpe_Id={3}", data.lctn_tpe, data.lctn_tpe_dsc,data.lctn_tpe_active,data.lctn_tpe_Id);
                    
            }
            catch (Exception ex)
            {
                string error = ex.Message.ToString();
              
            }
            return RedirectToAction("LocationTypes");

        }
       
        public ActionResult DeleteLocationType(string type,string desc)
        {
            try
            {
                int count = db.Database.ExecuteSqlCommand("exec sp_D_tblLctnTpe @lctn_tpe={0},@lctn_tpe_dsc={1}", type, desc);

            }
            catch (Exception ex)
            {
                string error = ex.Message.ToString();

            }
            return RedirectToAction("LocationTypes");

        }


        public ActionResult Locations()
        {
            IEnumerable<tblLocations> locationList = db.Database.SqlQuery
                                                                           <tblLocations>("select * from udfGetLocations()").ToList();

            return View(locationList);
            
        }
        [HttpGet]
        public ActionResult EditLocation(int LocationId)
        {
           
            IEnumerable<tblLocationType> locationTypesList = db.Database.SqlQuery
                                                                             <tblLocationType>("select * from udfGetLocationTypes()").ToList();



            ViewBag.TypeList = locationTypesList;

            tblLocations locationList = db.Database.SqlQuery
                                                                            <tblLocations>("select * from udfGetLocations() where lctn_Id = {0}  ", LocationId).FirstOrDefault();

            return View(locationList);
        }
        
        [HttpPost]
        public ActionResult EditLocation(tblLocations data)
        {
            try
            {
                int count = db.Database.ExecuteSqlCommand("exec sp_I_tblLctns @lctn_tpe={0},@lctn_nme={1},@lctn_dsc={2},@lctn_UnqID={3},@lctn_address={4},@lctn_active={5},@lctn_dflt={6},@lctn_Id={7}", data.lctn_tpe, data.lctn_nme, data.lctn_dsc, data.lctn_UnqID,data.lctn_address,data.lctn_active,data.lctn_dflt,data.lctn_Id);


            }
            catch (Exception ex)
            {
                string error = ex.Message.ToString();

            }
            return RedirectToAction("Locations");

        }
        [HttpGet]
        public ActionResult AddLocation(string type)
        {
            string loctionType = type;
            IEnumerable<tblLocationType> locationTypesList = db.Database.SqlQuery
                                                                             <tblLocationType>("select * from udfGetLocationTypes()").ToList();



            ViewBag.TypeList = locationTypesList;
            if (type == "" || type == null)
            {
                tblLocations locationsList = new tblLocations();
                return View("EditLocation", locationsList);
            }

            return View();
        }
        public ActionResult DeleteLocation(string LocationId)
        {
            try
            {
                int count = db.Database.ExecuteSqlCommand("exec sp_D_tblLctns @lctn_Id={0}", LocationId);

            }
            catch (Exception ex)
            {
                string error = ex.Message.ToString();

            }
            return RedirectToAction("Locations");

        }
        public ActionResult Customers()
        {
            IEnumerable<tblCustomers> customersList = db.Database.SqlQuery
                                                                           <tblCustomers>("select * from udfGetCstmrs()").ToList();

            return View(customersList);

        }
        [HttpGet]
        public ActionResult CreateCustomers()
        {
            tblCustomers List = new tblCustomers();
            return View(List);

        }
        [HttpPost]
        public ActionResult CreateCustomers(tblCustomers customer)
        {

            string Email = User.Identity.Name;

            try
            {
                int count = db.Database.ExecuteSqlCommand("exec sp_I_tblCstmrs @CstmrFN={0},@CstmrLN={1},@CstmrEml={2},@CstmrPhn1={3},@CstmrPhn2={4},@CstmrCrtdBy={5},@CstmrActv={6}", 
                    customer.CstmrFN, customer.CstmrLN, customer.CstmrEml, customer.CstmrPhn1, customer.CstmrPhn2, Email,customer.CstmrActv);


            }
            catch (Exception ex)
            {
                string error = ex.Message.ToString();

            }
            return RedirectToAction("Customers");
        }

        public JsonResult GetCustomerByEmail(string Email)
        {
            if(Email != "" && Email != null)
            {
                IEnumerable<tblCustomers> customer = db.Database.SqlQuery
                                                                             <tblCustomers>("select * from udfGetCstmrByEml('" + Email + "') ").ToList();
                return Json(customer, JsonRequestBehavior.AllowGet);
            }
            else
            {
                return Json("", JsonRequestBehavior.AllowGet);
            }
            
        
        }
        [HttpGet]
        public ActionResult EditCustomer(Int64 CustomerId)
        {

            tblCustomers customersList = db.Database.SqlQuery
                                                                           <tblCustomers>("select * from udfGetCstmrs() where CstmrId= {0}", CustomerId).FirstOrDefault();
           
            return View("CreateCustomers", customersList);

        }

        [HttpPost]
        public ActionResult EditCustomer(tblCustomers customer)
        {
            string Email = User.Identity.Name;
            try
            {
                int count = db.Database.ExecuteSqlCommand("exec sp_I_tblCstmrs @CstmrFN={0},@CstmrLN={1},@CstmrEml={2},@CstmrPhn1={3},@CstmrPhn2={4},@CstmrCrtdBy={5},@CstmrActv={6},@CstmrID={7}",
                    customer.CstmrFN, customer.CstmrLN, customer.CstmrEml, customer.CstmrPhn1, customer.CstmrPhn2, Email, customer.CstmrActv,customer.CstmrID);


            }
            catch (Exception ex)
            {
                string error = ex.Message.ToString();

            }
            return RedirectToAction("Customers");

        }
        public ActionResult DeleteCustomer(string CustomerId)
        {
            try
            {
                int count = db.Database.ExecuteSqlCommand("exec sp_D_tblCstmrs @CstmrID={0}", CustomerId);

            }
            catch (Exception ex)
            {
                string error = ex.Message.ToString();

            }
            return RedirectToAction("Customers");

        }

        public JsonResult GetLocationsByType(string type)
        {
            IEnumerable<tblLocations> locationList = db.Database.SqlQuery
                                                                           <tblLocations>("select * from udfGetLocations() where lctn_tpe = {0}", type).ToList();


            return Json(locationList, JsonRequestBehavior.AllowGet);

        }
    }
}
