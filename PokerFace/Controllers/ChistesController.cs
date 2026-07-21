using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Pokerface.Data;

namespace Pokerface.Controllers;

[ApiController]
[Route("[controller]")]
public class ChistesController : ControllerBase
{
    private readonly AppDbContext _context;

    public ChistesController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> Get()
    {
        var chiste = await _context.Chistes
            .OrderBy(r => EF.Functions.Random())
            .FirstOrDefaultAsync();

        if (chiste == null)
            return NotFound("No hay chistes disponibles.");

        return Ok(new
        {
            mensaje = "🤡 ¡Toma este chiste medio agrio!",
            chiste = chiste.Texto
        });
    }
}